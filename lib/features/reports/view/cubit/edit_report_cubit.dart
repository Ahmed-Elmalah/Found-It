import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/update_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_state.dart';
import 'package:found_it/features/reports/view/ui/widgets/verification_questions_form.dart';

class EditReportCubit extends Cubit<EditReportState> {
  EditReportCubit(
    ReportEntity report,
    this._updateReportUseCase,
    this._getCategoriesUseCase,
    this._getCityAreasUseCase,
  ) : super(EditReportState(
          report: report,
          selectedType: report.type,
          selectedCategoryId: report.categoryId,
          selectedAreaId: report.areaId,
          selectedDate: report.itemDate,
          questions: report.questions != null && report.questions!.isNotEmpty
              ? report.questions!.map((q) => QuestionDraft.fromEntity(q)).toList()
              : (report.type == 'found' ? [QuestionDraft()] : const []),
        ));

  final UpdateReportUseCase _updateReportUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCityAreasUseCase _getCityAreasUseCase;

  Future<void> init({String lang = 'en'}) async {
    emit(state.copyWith(
      status: EditReportStatus.loading,
      failure: () => null,
    ));
    try {
      final results = await Future.wait([
        _getCategoriesUseCase(),
        _getCityAreasUseCase(cityId: state.report.cityId, lang: lang),
      ]);

      final categories = results[0] as dynamic;
      final areas = results[1] as dynamic;

      emit(state.copyWith(
        status: EditReportStatus.ready,
        categories: categories,
        areas: areas,
      ));
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        failure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        failure: () => ReportFailureType.unknown,
      ));
    }
  }

  void typeChanged(String type) {
    final questions = type == 'found' && state.questions.isEmpty
        ? [QuestionDraft()]
        : state.questions;
    emit(state.copyWith(
      selectedType: type,
      questions: questions,
      clearQuestionsError: true,
    ));
  }

  void updateQuestions(List<QuestionDraft> questions) {
    emit(state.copyWith(
      questions: questions,
      clearQuestionsError: true,
    ));
  }

  void categoryChanged(String categoryId) {
    emit(state.copyWith(selectedCategoryId: categoryId));
  }

  void areaChanged(String areaId) {
    emit(state.copyWith(selectedAreaId: areaId));
  }

  void dateChanged(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  Future<bool> submit({
    required String title,
    String? description,
    String? privateDetails,
  }) async {
    String? qError;
    if (state.selectedType == 'found') {
      if (state.questions.isEmpty) {
        qError = 'At least 1 verification question is required for found items.';
      } else {
        for (final q in state.questions) {
          if (q.question.trim().length < 3) {
            qError = 'Question must be at least 3 characters.';
            break;
          }
          if (q.correct.trim().isEmpty || q.wrong.any((w) => w.trim().isEmpty)) {
            qError = 'All answers are required.';
            break;
          }
          final answers = [
            q.correct.trim().toLowerCase(),
            ...q.wrong.map((w) => w.trim().toLowerCase()),
          ];
          if (answers.toSet().length != answers.length) {
            qError = 'All choices for a question must be unique.';
            break;
          }
        }
      }
    }

    if (qError != null) {
      emit(state.copyWith(questionsError: qError));
      return false;
    }

    emit(state.copyWith(
      status: EditReportStatus.submitting,
      failure: () => null,
      clearQuestionsError: true,
    ));

    try {
      final updatedReport = await _updateReportUseCase(
        reportId: state.report.id,
        title: title,
        description: description,
        type: state.selectedType,
        categoryId: state.selectedCategoryId,
        areaId: state.selectedAreaId,
        itemDate: state.selectedDate,
        privateDetails: privateDetails,
        questions: state.selectedType == 'found'
            ? state.questions.map((q) => q.toJson()).toList()
            : null,
      );

      emit(state.copyWith(
        status: EditReportStatus.success,
        report: updatedReport,
      ));
      return true;
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        failure: () => e.type,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        failure: () => ReportFailureType.unknown,
      ));
      return false;
    }
  }
}
