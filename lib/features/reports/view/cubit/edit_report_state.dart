import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/view/ui/widgets/verification_questions_form.dart';

enum EditReportStatus { initial, loading, ready, submitting, success, failure }

class EditReportState extends Equatable {
  const EditReportState({
    required this.report,
    this.status = EditReportStatus.initial,
    this.categories = const [],
    this.areas = const [],
    this.selectedType = 'lost',
    this.selectedCategoryId,
    this.selectedAreaId,
    this.selectedDate,
    this.failure,
    this.questions = const [],
    this.questionsError,
  });

  final ReportEntity report;
  final EditReportStatus status;
  final List<CategoryEntity> categories;
  final List<AreaEntity> areas;
  final String selectedType;
  final String? selectedCategoryId;
  final String? selectedAreaId;
  final DateTime? selectedDate;
  final ReportFailureType? failure;
  final List<QuestionDraft> questions;
  final QuestionsError? questionsError;

  bool get isLoading => status == EditReportStatus.loading;
  bool get isSubmitting => status == EditReportStatus.submitting;
  bool get isSuccess => status == EditReportStatus.success;

  EditReportState copyWith({
    ReportEntity? report,
    EditReportStatus? status,
    List<CategoryEntity>? categories,
    List<AreaEntity>? areas,
    String? selectedType,
    String? selectedCategoryId,
    String? selectedAreaId,
    DateTime? selectedDate,
    ReportFailureType? Function()? failure,
    List<QuestionDraft>? questions,
    QuestionsError? questionsError,
    bool clearQuestionsError = false,
  }) {
    return EditReportState(
      report: report ?? this.report,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      selectedType: selectedType ?? this.selectedType,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedAreaId: selectedAreaId ?? this.selectedAreaId,
      selectedDate: selectedDate ?? this.selectedDate,
      failure: failure != null ? failure() : this.failure,
      questions: questions ?? this.questions,
      questionsError: clearQuestionsError
          ? null
          : (questionsError ?? this.questionsError),
    );
  }

  @override
  List<Object?> get props => [
        report,
        status,
        categories,
        areas,
        selectedType,
        selectedCategoryId,
        selectedAreaId,
        selectedDate,
        failure,
        questions,
        questionsError,
      ];
}
