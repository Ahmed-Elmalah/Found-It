import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';

enum MyReportsStatus { initial, loading, success, failure }

enum MyReportsFilter {
  all,
  active,
  matching,
  recovered;

  String? get apiStatus => switch (this) {
        MyReportsFilter.all => null,
        MyReportsFilter.active => 'active',
        MyReportsFilter.matching => 'matching',
        MyReportsFilter.recovered => 'recovered',
      };
}

class MyReportsState extends Equatable {
  const MyReportsState({
    this.status = MyReportsStatus.initial,
    this.reports = const [],
    this.counts = const ReportCountsEntity.empty(),
    this.selectedFilter = MyReportsFilter.all,
    this.isDeleting = false,
    this.deletingReportId,
    this.failure,
  });

  final MyReportsStatus status;
  final List<ReportEntity> reports;
  final ReportCountsEntity counts;
  final MyReportsFilter selectedFilter;
  final bool isDeleting;
  final String? deletingReportId;
  final ReportFailureType? failure;

  bool get isLoading => status == MyReportsStatus.loading;
  bool get isSuccess => status == MyReportsStatus.success;
  bool get isFailure => status == MyReportsStatus.failure;

  MyReportsState copyWith({
    MyReportsStatus? status,
    List<ReportEntity>? reports,
    ReportCountsEntity? counts,
    MyReportsFilter? selectedFilter,
    bool? isDeleting,
    String? deletingReportId,
    ReportFailureType? Function()? failure,
  }) {
    return MyReportsState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      counts: counts ?? this.counts,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isDeleting: isDeleting ?? this.isDeleting,
      deletingReportId: deletingReportId ?? this.deletingReportId,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        counts,
        selectedFilter,
        isDeleting,
        deletingReportId,
        failure,
      ];
}
