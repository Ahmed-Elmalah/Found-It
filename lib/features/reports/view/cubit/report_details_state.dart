import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';

enum ReportDetailsStatus { initial, loading, success, failure }

enum ClaimStatus { initial, loading, success, failure }

class ReportDetailsState extends Equatable {
  const ReportDetailsState({
    this.status = ReportDetailsStatus.initial,
    this.report,
    this.failure,
    this.claimStatus = ClaimStatus.initial,
    this.claimResult,
    this.claimFailure,
  });

  final ReportDetailsStatus status;
  final ReportDetailsEntity? report;
  final ReportFailureType? failure;
  final ClaimStatus claimStatus;
  final ManualMatchResultEntity? claimResult;
  final ReportFailureType? claimFailure;

  bool get isLoading => status == ReportDetailsStatus.loading;
  bool get isSuccess => status == ReportDetailsStatus.success && report != null;
  bool get isFailure => status == ReportDetailsStatus.failure;
  bool get isNotFound => failure == ReportFailureType.notFound;
  bool get isClaimLoading => claimStatus == ClaimStatus.loading;

  ReportDetailsState copyWith({
    ReportDetailsStatus? status,
    ReportDetailsEntity? Function()? report,
    ReportFailureType? Function()? failure,
    ClaimStatus? claimStatus,
    ManualMatchResultEntity? Function()? claimResult,
    ReportFailureType? Function()? claimFailure,
  }) {
    return ReportDetailsState(
      status: status ?? this.status,
      report: report != null ? report() : this.report,
      failure: failure != null ? failure() : this.failure,
      claimStatus: claimStatus ?? this.claimStatus,
      claimResult: claimResult != null ? claimResult() : this.claimResult,
      claimFailure: claimFailure != null ? claimFailure() : this.claimFailure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        failure,
        claimStatus,
        claimResult,
        claimFailure,
      ];
}
