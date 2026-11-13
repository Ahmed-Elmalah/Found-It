import 'package:equatable/equatable.dart';

import '../../domain/entities/home_report_item.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  failure,
}

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.reports = const [],
    this.selectedCityId = '',
    this.selectedCityName = 'Cairo',
    this.errorMessage,
  });

  final HomeStatus status;
  final List<HomeReportItem> reports;
  final String selectedCityId;
  final String selectedCityName;
  final String? errorMessage;

  bool get isLoading => status == HomeStatus.loading;
  bool get isSuccess => status == HomeStatus.success;
  bool get isFailure => status == HomeStatus.failure;
  bool get isEmpty => isSuccess && reports.isEmpty;

  HomeState copyWith({
    HomeStatus? status,
    List<HomeReportItem>? reports,
    String? selectedCityId,
    String? selectedCityName,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      selectedCityName: selectedCityName ?? this.selectedCityName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        selectedCityId,
        selectedCityName,
        errorMessage,
      ];
}
