import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/explore_failure.dart';
import 'package:found_it/features/explore/domain/get_categories_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_areas_use_case.dart';
import 'package:found_it/features/explore/domain/get_current_city_use_case.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';
import 'package:found_it/features/explore/domain/search_reports_use_case.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';

/// Owns the Explore search: city context, categories, areas, filters and
/// the debounced `search_reports` call.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required GetCurrentCityUseCase getCurrentCity,
    required SearchReportsUseCase searchReports,
    required GetCategoriesUseCase getCategories,
    required GetCityAreasUseCase getCityAreas,
  })
    // ignore: prefer_initializing_formals
    : _getCurrentCity = getCurrentCity,
       // ignore: prefer_initializing_formals
       _searchReports = searchReports,
       // ignore: prefer_initializing_formals
       _getCategories = getCategories,
       // ignore: prefer_initializing_formals
       _getCityAreas = getCityAreas,
       super(const SearchState());

  final GetCurrentCityUseCase _getCurrentCity;
  final SearchReportsUseCase _searchReports;
  final GetCategoriesUseCase _getCategories;
  final GetCityAreasUseCase _getCityAreas;

  Timer? _debounce;
  String? _cityId;
  int _requestToken = 0;

  /// Resolves the city, loads the filters data and runs the first search.
  Future<void> init() async {
    _debounce?.cancel();
    final token = ++_requestToken;
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));

    try {
      final city = await _getCurrentCity();
      _cityId = city.id;

      final categories = await _getCategories();
      final areas = await _getCityAreas(cityId: city.id);
      final results = await _runSearch(city.id);

      if (_isStale(token)) return;
      emit(
        state.copyWith(
          status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
          results: results,
          categories: [
            for (final category in categories)
              CategoryOption(
                id: category.id,
                nameEn: category.nameEn,
                nameAr: category.nameAr,
              ),
          ],
          areas: [
            for (final area in areas)
              AreaOption(id: area.id, nameEn: area.nameEn, nameAr: area.nameAr),
          ],
          cityNameEn: city.nameEn,
          cityNameAr: city.nameAr,
          clearError: true,
        ),
      );
    } catch (error) {
      if (_isStale(token)) return;
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          results: const [],
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  /// Debounces typing so one search runs after [AppDurations.searchDebounce].
  void onQueryChanged(String value) {
    if (state.query == value) return;
    emit(state.copyWith(query: value, clearError: true));

    _debounce?.cancel();
    _debounce = Timer(AppDurations.searchDebounce, search);
  }

  /// Replaces every filter with the values chosen in the sheet.
  Future<void> applyFilters({
    ReportType? type,
    List<String>? categoryIds,
    List<String>? areaIds,
    String? dateFrom,
    String? dateTo,
  }) async {
    emit(
      SearchState(
        status: state.status,
        query: state.query,
        type: type,
        categoryIds: categoryIds ?? const [],
        areaIds: areaIds ?? const [],
        dateFrom: dateFrom,
        dateTo: dateTo,
        results: state.results,
        categories: state.categories,
        areas: state.areas,
        cityNameEn: state.cityNameEn,
        cityNameAr: state.cityNameAr,
      ),
    );
    await search();
  }

  Future<void> removeCategoryFilter(String id) async {
    emit(
      state.copyWith(
        categoryIds: [
          for (final categoryId in state.categoryIds)
            if (categoryId != id) categoryId,
        ],
      ),
    );
    await search();
  }

  Future<void> removeAreaFilter(String id) async {
    emit(
      state.copyWith(
        areaIds: [
          for (final areaId in state.areaIds)
            if (areaId != id) areaId,
        ],
      ),
    );
    await search();
  }

  Future<void> clearDateFilter() async {
    emit(state.copyWith(clearDates: true));
    await search();
  }

  Future<void> clearTypeFilter() async {
    emit(state.copyWith(clearType: true));
    await search();
  }

  /// Clears the query and every filter, then searches again.
  Future<void> resetFilters() async {
    _debounce?.cancel();
    emit(
      SearchState(
        status: state.status,
        results: state.results,
        categories: state.categories,
        areas: state.areas,
        cityNameEn: state.cityNameEn,
        cityNameAr: state.cityNameAr,
      ),
    );
    await search();
  }

  /// Runs the current query + filters. Used by Retry and by the debounce.
  Future<void> search() async {
    _debounce?.cancel();
    final cityId = _cityId;
    if (cityId == null) {
      await init();
      return;
    }

    final token = ++_requestToken;
    emit(state.copyWith(status: SearchStatus.loading, clearError: true));

    try {
      final results = await _runSearch(cityId);
      if (_isStale(token)) return;
      emit(
        state.copyWith(
          status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
          results: results,
          clearError: true,
        ),
      );
    } catch (error) {
      if (_isStale(token)) return;
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          results: const [],
          errorMessage: _messageFor(error),
        ),
      );
    }
  }

  Future<List<ReportEntity>> _runSearch(String cityId) {
    return _searchReports(
      cityId: cityId,
      query: state.query,
      type: state.type,
      categoryIds: state.categoryIds,
      areaIds: state.areaIds,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }

  bool _isStale(int token) => isClosed || token != _requestToken;

  String _messageFor(Object error) {
    if (error is ExploreFailure) return error.message;
    return error.toString();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
