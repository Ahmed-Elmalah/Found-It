import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_counts_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_my_reports_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/soft_delete_report_use_case.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';

class MyReportsCubit extends Cubit<MyReportsState> {
  MyReportsCubit(
    this._getMyReportsUseCase,
    this._getMyReportsCountsUseCase,
    this._softDeleteReportUseCase,
  ) : super(const MyReportsState());

  final GetMyReportsUseCase _getMyReportsUseCase;
  final GetMyReportsCountsUseCase _getMyReportsCountsUseCase;
  final SoftDeleteReportUseCase _softDeleteReportUseCase;

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
