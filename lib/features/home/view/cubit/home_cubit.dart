import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getHomeFeedUseCase,
    required this.getCitiesUseCase,
    required this.selectCityUseCase,
    this.getMyMatchesCountUseCase,
    ReportsChangedNotifier? reportsChangedNotifier,
  }) : super(const HomeState()) {
    _reportsChangedSubscription =
        reportsChangedNotifier?.stream.listen((_) => refresh());
  }

  final GetHomeFeedUseCase getHomeFeedUseCase;
  final GetCitiesUseCase getCitiesUseCase;
  final SelectCityUseCase selectCityUseCase;
  final GetMyMatchesCountUseCase? getMyMatchesCountUseCase;
  StreamSubscription<void>? _reportsChangedSubscription;

  List<CityEntity> _cachedCities = const [];
  List<CityEntity> get cachedCities => _cachedCities;

  /// Loads available cities and initial home feed using the authenticated user's city.
  Future<void> init({
    String? initialCityId,
  }) async {
    emit(state.copyWith(status: HomeStatus.loading, clearFailure: true));

    String cityId = initialCityId ?? '';
    CityEntity? city;

    try {
      _cachedCities = await getCitiesUseCase();
    } catch (_) {
      // Offline fallback: keep cachedCities empty
    }

    if (_cachedCities.isNotEmpty) {
      if (cityId.isNotEmpty) {
        city = _cachedCities.where((c) => c.id == cityId).firstOrNull;
      }
      city ??= _cachedCities.first;
      cityId = city.id;
    }

    emit(state.copyWith(
      selectedCityId: cityId,
      selectedCity: city,
    ));

    await _fetchFeed(cityId: cityId);
  }

  /// Changes the active city by persisting to database profile and updating [AuthCubit].
  Future<void> selectCity(
    CityEntity city, {
    void Function(String)? onCitySyncedToAuth,
  }) async {
    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCityId: city.id,
      selectedCity: city,
      clearFailure: true,
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
  Future<void> onCityChangedFromAuth(String newCityId) async {
    if (newCityId == state.selectedCityId && state.reports.isNotEmpty) return;

    CityEntity? city;
    if (_cachedCities.isNotEmpty) {
      city = _cachedCities.where((c) => c.id == newCityId).firstOrNull;
    }

    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCityId: newCityId,
      selectedCity: city,
      clearFailure: true,
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
        clearFailure: true,
      ));
      return;
    }

    try {
      int matchesCount = state.potentialMatchesCount;
      if (getMyMatchesCountUseCase != null) {
        try {
          matchesCount = await getMyMatchesCountUseCase!();
        } catch (_) {
          // Keep existing matches count if call fails
        }
      }

      final reports = await getHomeFeedUseCase(
        cityId: cityId,
        type: 'found',
      );

      emit(state.copyWith(
        status: HomeStatus.success,
        reports: reports,
        potentialMatchesCount: matchesCount,
        clearFailure: true,
      ));
    } catch (e) {
      final failure = e is HomeFailure
          ? e
          : const HomeFailure(HomeFailureType.unknown);

      emit(state.copyWith(
        status: HomeStatus.failure,
        failure: failure,
      ));
    }
  }

  @override
  Future<void> close() {
    _reportsChangedSubscription?.cancel();
    return super.close();
  }
}
