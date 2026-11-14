part of 'city_cubit.dart';

enum CityStatus { initial, loading, loaded, submitting, success, failure }

final class CityState extends Equatable {
  const CityState({
    this.status = CityStatus.initial,
    this.cities = const [],
    this.selectedCityId,
    this.hasLocationRequiredError = false,
    this.errorMessage,
  });

  final CityStatus status;
  final List<CityEntity> cities;
  final String? selectedCityId;
  final bool hasLocationRequiredError;
  final String? errorMessage;

  bool get isLoading => status == CityStatus.loading;
  bool get isSubmitting => status == CityStatus.submitting;

  CityEntity? get selectedCity {
    if (selectedCityId == null) return null;
    try {
      return cities.firstWhere((c) => c.id == selectedCityId);
    } catch (_) {
      return null;
    }
  }

  CityState copyWith({
    CityStatus? status,
    List<CityEntity>? cities,
    String? selectedCityId,
    bool? hasLocationRequiredError,
    String? errorMessage,
  }) =>
      CityState(
        status: status ?? this.status,
        cities: cities ?? this.cities,
        selectedCityId: selectedCityId ?? this.selectedCityId,
        hasLocationRequiredError:
            hasLocationRequiredError ?? this.hasLocationRequiredError,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        cities,
        selectedCityId,
        hasLocationRequiredError,
        errorMessage,
      ];
}
