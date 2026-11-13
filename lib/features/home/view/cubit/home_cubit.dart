import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/city/data/city_local_data_source.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import '../../domain/entities/home_failure.dart';
import '../../domain/entities/home_report_item.dart';
import '../../domain/use_cases/get_home_feed_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getHomeFeedUseCase,
    required this.cityLocalDataSource,
    required this.getCitiesUseCase,
  }) : super(const HomeState());

  final GetHomeFeedUseCase getHomeFeedUseCase;
  final CityLocalDataSource cityLocalDataSource;
  final GetCitiesUseCase getCitiesUseCase;

  List<CityEntity> _cachedCities = const [];
  List<CityEntity> get cachedCities => _cachedCities;

  /// Loads available cities and initial home feed.
  Future<void> init({String? initialCityId, String? initialCityName}) async {
    emit(state.copyWith(status: HomeStatus.loading));

    String cityId = initialCityId ?? '';
    String cityName = initialCityName ?? state.selectedCityName;

    try {
      _cachedCities = await getCitiesUseCase();
    } catch (_) {
      // In offline/fallback mode, keep cachedCities empty
    }

    if (cityId.isEmpty) {
      final savedId = cityLocalDataSource.getSelectedCityId();
      if (savedId != null && savedId.isNotEmpty) {
        cityId = savedId;
      }
    }

    if (_cachedCities.isNotEmpty) {
      CityEntity? match;
      if (cityId.isNotEmpty) {
        match = _cachedCities.where((c) => c.id == cityId).firstOrNull;
      }
      match ??= _cachedCities.first;
      cityId = match.id;
      cityName = match.nameAr; // Default display name
    }

    emit(state.copyWith(
      selectedCityId: cityId,
      selectedCityName: cityName,
    ));

    await _fetchFeed(cityId: cityId);
  }

  /// Changes the active city and fetches its feed immediately.
  Future<void> selectCity(CityEntity city, {String locale = 'ar'}) async {
    final cityName = city.localizedName(locale);

    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCityId: city.id,
      selectedCityName: cityName,
    ));

    try {
      await cityLocalDataSource.saveSelectedCityId(city.id);
    } catch (_) {
      // Ignore local storage error
    }

    await _fetchFeed(cityId: city.id);
  }

  /// Pull-to-refresh or retry.
  Future<void> refresh() async {
    await _fetchFeed(cityId: state.selectedCityId);
  }

  /// Preview state override (used for UI state switcher toggles).
  void setPreviewStatus(HomeStatus status, {List<HomeReportItem>? reports, String? errorMessage}) {
    emit(state.copyWith(
      status: status,
      reports: reports,
      errorMessage: errorMessage,
    ));
  }

  Future<void> _fetchFeed({required String cityId}) async {
    if (cityId.isEmpty) {
      emit(state.copyWith(
        status: HomeStatus.success,
        reports: const [],
      ));
      return;
    }

    try {
      final reports = await getHomeFeedUseCase(
        cityId: cityId,
        type: 'found',
      );

      emit(state.copyWith(
        status: HomeStatus.success,
        reports: reports,
        errorMessage: null,
      ));
    } catch (e) {
      final message = e is HomeFailure && e.message != null
          ? e.message
          : 'Failed to load home feed';

      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: message,
      ));
    }
  }
}
