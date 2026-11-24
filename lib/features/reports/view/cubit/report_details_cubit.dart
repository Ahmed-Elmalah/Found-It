import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/use_cases/create_manual_match_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_report_details_use_case.dart';
import 'package:found_it/features/reports/view/cubit/report_details_state.dart';

class ReportDetailsCubit extends Cubit<ReportDetailsState> {
  ReportDetailsCubit(
    this._getReportDetailsUseCase,
    this._createManualMatchUseCase,
  ) : super(const ReportDetailsState());

  final GetReportDetailsUseCase _getReportDetailsUseCase;
  final CreateManualMatchUseCase _createManualMatchUseCase;

  String? _currentReportId;

  Future<void> loadReport(String reportId) async {
    _currentReportId = reportId;
    emit(state.copyWith(
      status: ReportDetailsStatus.loading,
      failure: () => null,
      claimStatus: ClaimStatus.initial,
      claimResult: () => null,
      claimFailure: () => null,
    ));

    try {
      final report = await _getReportDetailsUseCase(reportId);
      emit(state.copyWith(
        status: ReportDetailsStatus.success,
        report: () => report,
      ));
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        status: ReportDetailsStatus.failure,
        failure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ReportDetailsStatus.failure,
        failure: () => ReportFailureType.unknown,
      ));
    }
  }

  Future<void> refresh() async {
    if (_currentReportId != null) {
      await loadReport(_currentReportId!);
    }
  }

  Future<void> claimReport() async {
    final report = state.report;
    if (report == null) return;

    emit(state.copyWith(
      claimStatus: ClaimStatus.loading,
      claimFailure: () => null,
    ));

    try {
      final result = await _createManualMatchUseCase(report.id);
      emit(state.copyWith(
        claimStatus: ClaimStatus.success,
        claimResult: () => result,
      ));
    } on ReportFailure catch (e) {
      emit(state.copyWith(
        claimStatus: ClaimStatus.failure,
        claimFailure: () => e.type,
      ));
    } catch (_) {
      emit(state.copyWith(
        claimStatus: ClaimStatus.failure,
        claimFailure: () => ReportFailureType.unknown,
      ));
    }
  }

  void resetClaimStatus() {
    emit(state.copyWith(
      claimStatus: ClaimStatus.initial,
      claimResult: () => null,
      claimFailure: () => null,
    ));
  }
}
