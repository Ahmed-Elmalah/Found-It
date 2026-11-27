import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';

class MyReportsCubit extends Cubit<MyReportsState> {
  MyReportsCubit(
    this._getMyReportsUseCase,
    this._getMyReportsCountsUseCase,
    this._softDeleteReportUseCase, [
    this._getReportDetailsUseCase,
  ]) : super(const MyReportsState());

  final GetMyReportsUseCase _getMyReportsUseCase;
  final GetMyReportsCountsUseCase _getMyReportsCountsUseCase;
  final SoftDeleteReportUseCase _softDeleteReportUseCase;
  final GetReportDetailsUseCase? _getReportDetailsUseCase;

  GetReportDetailsUseCase? get getReportDetailsUseCase => _getReportDetailsUseCase;

  Future<ReportDetailsEntity> getReportDetails(String reportId) async {
    final useCase = _getReportDetailsUseCase ??
        (sl.isRegistered<GetReportDetailsUseCase>()
            ? sl<GetReportDetailsUseCase>()
            : null);
    if (useCase == null) {
      throw const ReportFailure(ReportFailureType.unknown);
    }
    return useCase(reportId);
  }

  Future<void> loadReports({MyReportsFilter? filter}) async {
    final activeFilter = filter ?? state.selectedFilter;
    emit(state.copyWith(
      status: MyReportsStatus.loading,
      selectedFilter: activeFilter,
      failure: () => null,
    ));

    try {
      final results = await Future.wait([
        _getMyReportsUseCase(status: activeFilter.apiStatus),
        _getMyReportsCountsUseCase(),
      ]);

      final reports = results[0] as dynamic;
      final counts = results[1] as dynamic;

      emit(state.copyWith(
        status: MyReportsStatus.success,
        reports: reports,
        counts: counts,
      ));
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        status: MyReportsStatus.failure,
        failure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: MyReportsStatus.failure,
        failure: () => ReportFailureType.unknown,
      ));
    }
  }

  void setFilter(MyReportsFilter filter) {
    if (state.selectedFilter == filter && state.status == MyReportsStatus.success) {
      return;
    }
    loadReports(filter: filter);
  }

  Future<bool> deleteReport(String reportId) async {
    emit(state.copyWith(
      isDeleting: true,
      deletingReportId: reportId,
      failure: () => null,
    ));

    try {
      await _softDeleteReportUseCase(reportId);
      emit(state.copyWith(
        isDeleting: false,
        deletingReportId: null,
      ));
      // Refresh current tab and counts
      await loadReports();
      return true;
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        deletingReportId: null,
        failure: () => e.type,
      ));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isDeleting: false,
        deletingReportId: null,
        failure: () => ReportFailureType.unknown,
      ));
      return false;
    }
  }

  Future<void> refresh() => loadReports();
}
