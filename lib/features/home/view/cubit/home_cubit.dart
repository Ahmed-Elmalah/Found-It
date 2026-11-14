import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getHomeFeedUseCase,
    required this.getCitiesUseCase,
    required this.selectCityUseCase,
  }) : super(const HomeState());

  final GetHomeFeedUseCase getHomeFeedUseCase;
  final GetCitiesUseCase getCitiesUseCase;
  final SelectCityUseCase selectCityUseCase;

  List<CityEntity> _cachedCities = const [];
  List<CityEntity> get cachedCities => _cachedCities;

  /// Loads available cities and initial home feed using the authenticated user's city.
  Future<void> init({
    String? initialCityId,
    String? initialCityName,
    String locale = 'ar',
  }) async {
    emit(state.copyWith(status: HomeStatus.loading));

    String cityId = initialCityId ?? '';
    String cityName = initialCityName ?? state.selectedCityName;

    try {
      _cachedCities = await getCitiesUseCase();
    } catch (_) {
      // Offline fallback: keep cachedCities empty
    }

    if (_cachedCities.isNotEmpty) {
      CityEntity? match;
      if (cityId.isNotEmpty) {
        match = _cachedCities.where((c) => c.id == cityId).firstOrNull;
      }
      match ??= _cachedCities.first;
      cityId = match.id;
      cityName = match.localizedName(locale);
    }

    emit(state.copyWith(
      selectedCityId: cityId,
      selectedCityName: cityName,
    ));

    await _fetchFeed(cityId: cityId);
  }

  /// Changes the active city by persisting to database profile and updating [AuthCubit].
  Future<void> selectCity(
    CityEntity city, {
    void Function(String)? onCitySyncedToAuth,
    String locale = 'ar',
  }) async {
    final cityName = city.localizedName(locale);

    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCityId: city.id,
      selectedCityName: cityName,
    ));

    try {
      // 1. Persist to database profile via SelectCityUseCase
      await selectCityUseCase(city.id);
      // 2. Notify AuthCubit (Single source of truth)
      onCitySyncedToAuth?.call(city.id);
    } catch (_) {
      // Fallback: continue loading feed even if profile update fails temporarily
    }

    await _fetchFeed(cityId: city.id);
  }

  /// Called when the user's city in AuthCubit is updated (e.g. from Profile screen).
  Future<void> onCityChangedFromAuth(String newCityId, {String locale = 'ar'}) async {
    if (newCityId == state.selectedCityId && state.reports.isNotEmpty) return;

    String cityName = state.selectedCityName;
    if (_cachedCities.isNotEmpty) {
      final match = _cachedCities.where((c) => c.id == newCityId).firstOrNull;
      if (match != null) {
        cityName = match.localizedName(locale);
      }
    }

    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCityId: newCityId,
      selectedCityName: cityName,
    ));

    await _fetchFeed(cityId: newCityId);
  }

  /// Pull-to-refresh or retry.
  Future<void> refresh() async {
    await _fetchFeed(cityId: state.selectedCityId);
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
