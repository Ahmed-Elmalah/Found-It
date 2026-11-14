import 'package:equatable/equatable.dart';

import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:found_it/features/home/domain/entities/home_report_item.dart';

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
    this.selectedCity,
    this.failure,
  });

  final HomeStatus status;
  final List<HomeReportItem> reports;
  final String selectedCityId;
  final CityEntity? selectedCity;
  final HomeFailure? failure;

  bool get isLoading => status == HomeStatus.loading;
  bool get isSuccess => status == HomeStatus.success;
  bool get isFailure => status == HomeStatus.failure;
  bool get isEmpty => isSuccess && reports.isEmpty;

  HomeState copyWith({
    HomeStatus? status,
    List<HomeReportItem>? reports,
    String? selectedCityId,
    CityEntity? selectedCity,
    HomeFailure? failure,
    bool clearFailure = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      reports: reports ?? this.reports,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      selectedCity: selectedCity ?? this.selectedCity,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
        status,
        reports,
        selectedCityId,
        selectedCity,
        failure,
      ];
}
