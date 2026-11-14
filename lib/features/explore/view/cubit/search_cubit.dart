import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/get_categories_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_areas_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_by_id_use_case.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';
import 'package:found_it/features/explore/domain/search_reports_use_case.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';

/// Owns the Explore search: city context, categories, areas, filters and
/// the debounced `search_reports` call.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit({
    required GetCityByIdUseCase getCityById,
    required SearchReportsUseCase searchReports,
    required GetCategoriesUseCase getCategories,
    required GetCityAreasUseCase getCityAreas,
  })
    // ignore: prefer_initializing_formals
    : _getCityById = getCityById,
       // ignore: prefer_initializing_formals
       _searchReports = searchReports,
       // ignore: prefer_initializing_formals
       _getCategories = getCategories,
       // ignore: prefer_initializing_formals
       _getCityAreas = getCityAreas,
       super(const SearchState());

  final GetCityByIdUseCase _getCityById;
  final SearchReportsUseCase _searchReports;
  final GetCategoriesUseCase _getCategories;
  final GetCityAreasUseCase _getCityAreas;

  Timer? _debounce;

  /// Active app language, used to sort the areas returned by the backend.
  String _lang = 'en';

  int _requestToken = 0;

  /// Loads the user's city, the filter data and runs the first search.
  ///
  /// [cityId] comes from `AuthCubit`; [lang] is the active app language.
  Future<void> init({required String cityId, String lang = 'en'}) async {
    _debounce?.cancel();
    _lang = _normalizeLang(lang);

    final token = ++_requestToken;
    emit(state.copyWith(status: SearchStatus.loading, cityId: cityId));

    try {
      final city = await _getCityById(cityId);
      final categories = await _getCategories();
      final areas = await _fetchAreas(cityId);
      final results = await _runSearch(cityId);

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
          areas: areas,
          cityNameEn: city.nameEn,
          cityNameAr: city.nameAr,
        ),
      );
    } catch (_) {
      if (_isStale(token)) return;
      emit(state.copyWith(status: SearchStatus.failure, results: const []));
    }
  }

  /// Re-fetches the areas when the app language changes so they stay sorted
  /// for the active locale. The search results themselves are unaffected.
  Future<void> setLocale(String lang) async {
    final normalized = _normalizeLang(lang);
    if (_lang == normalized) return;
    _lang = normalized;

    final cityId = state.cityId;
    if (cityId == null) return;

    try {
      final areas = await _fetchAreas(cityId);
      if (isClosed || cityId != state.cityId) return;
      emit(state.copyWith(areas: areas));
    } catch (_) {
      // The previous areas are still usable; sorting is a cosmetic concern.
    }
  }

  /// Debounces typing so one search runs after [AppDurations.searchDebounce].
  void onQueryChanged(String value) {
    if (state.query == value) return;
    emit(state.copyWith(query: value));

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
        cityId: state.cityId,
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
        cityId: state.cityId,
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
    final cityId = state.cityId;
    if (cityId == null) return;

    final token = ++_requestToken;
    emit(state.copyWith(status: SearchStatus.loading));

    try {
      final results = await _runSearch(cityId);
      if (_isStale(token)) return;
      emit(
        state.copyWith(
          status: results.isEmpty ? SearchStatus.empty : SearchStatus.success,
          results: results,
        ),
      );
    } catch (_) {
      if (_isStale(token)) return;
      emit(state.copyWith(status: SearchStatus.failure, results: const []));
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

  Future<List<AreaOption>> _fetchAreas(String cityId) async {
    final lang = _lang;
    final areas = await _getCityAreas(cityId: cityId, lang: lang);
    if (!isClosed && lang != _lang) {
      // The locale changed while the request was running: fetch again.
      return _fetchAreas(cityId);
    }
    return [
      for (final area in areas)
        AreaOption(id: area.id, nameEn: area.nameEn, nameAr: area.nameAr),
    ];
  }

  bool _isStale(int token) => isClosed || token != _requestToken;

  static String _normalizeLang(String lang) =>
      lang.startsWith('ar') ? 'ar' : 'en';

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
