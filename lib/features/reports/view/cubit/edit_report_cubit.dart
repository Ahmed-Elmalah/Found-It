import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/update_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_state.dart';

class EditReportCubit extends Cubit<EditReportState> {
  EditReportCubit({
    required ReportEntity report,
    required UpdateReportUseCase updateReportUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetCityAreasUseCase getCityAreasUseCase,
  })  : _updateReportUseCase = updateReportUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getCityAreasUseCase = getCityAreasUseCase,
        super(EditReportState(
          report: report,
          selectedType: report.type,
          selectedCategoryId: report.categoryId,
          selectedAreaId: report.areaId,
          selectedDate: report.itemDate,
        ));

  final UpdateReportUseCase _updateReportUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCityAreasUseCase _getCityAreasUseCase;

  Future<void> init() async {
    emit(state.copyWith(status: EditReportStatus.loading));
    try {
      final results = await Future.wait([
        _getCategoriesUseCase(),
        _getCityAreasUseCase(cityId: state.report.cityId),
      ]);

      final categories = results[0] as dynamic;
      final areas = results[1] as dynamic;

      emit(state.copyWith(
        status: EditReportStatus.ready,
        categories: categories,
        areas: areas,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void typeChanged(String type) {
    emit(state.copyWith(selectedType: type));
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
  }) async {
    emit(state.copyWith(
      status: EditReportStatus.submitting,
      errorMessage: null,
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
      );

      emit(state.copyWith(
        status: EditReportStatus.success,
        report: updatedReport,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: EditReportStatus.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }
}
