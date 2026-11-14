import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/get_categories_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_areas_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_by_id_use_case.dart';
import 'package:found_it/features/explore/domain/search_reports_use_case.dart';
import 'package:found_it/features/explore/view/cubit/search_cubit.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';

import '../../helpers/fake_explore_repository.dart';

const _cityId = 'city-cairo';

void main() {
  group('SearchCubit', () {
    late FakeExploreRepository repository;
    late SearchCubit cubit;

    setUp(() {
      repository = FakeExploreRepository();
      cubit = SearchCubit(
        getCityById: GetCityByIdUseCase(repository),
        searchReports: SearchReportsUseCase(repository),
        getCategories: GetCategoriesUseCase(repository),
        getCityAreas: GetCityAreasUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('initial state is empty, has no city and no filters', () {
      expect(cubit.state.status, SearchStatus.initial);
      expect(cubit.state.cityId, isNull);
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.query, '');
      expect(cubit.state.hasActiveFilters, isFalse);
    });

    test(
      'init emits loading then success with reports and filter data',
      () async {
        final statuses = <SearchStatus>[];
        final subscription = cubit.stream.listen(
          (state) => statuses.add(state.status),
        );

        await cubit.init(cityId: _cityId);
        await pumpEventQueue();
        await subscription.cancel();

        expect(statuses.first, SearchStatus.loading);
        expect(statuses.last, SearchStatus.success);
        expect(cubit.state.cityId, _cityId);
        expect(repository.lastCityId, _cityId);
        expect(cubit.state.results, hasLength(3));
        expect(cubit.state.categories, hasLength(3));
        expect(cubit.state.areas, hasLength(2));
        expect(cubit.state.cityNameEn, 'Cairo');
        expect(cubit.state.cityNameAr, 'القاهرة');
        expect(repository.searchCalls, 1);
        expect(repository.lastQuery, isEmpty);
        expect(repository.lastAreaLang, 'en');
      },
    );

    test('init forwards the active language to get_city_areas', () async {
      await cubit.init(cityId: _cityId, lang: 'ar');

      expect(repository.lastAreaLang, 'ar');
      expect(cubit.state.status, SearchStatus.success);
    });

    test('setLocale re-fetches the areas with the new language', () async {
      await cubit.init(cityId: _cityId);
      repository.resetRecording();

      await cubit.setLocale('ar');

      expect(repository.lastAreaLang, 'ar');
      expect(repository.searchCalls, 0);
      expect(cubit.state.areas, hasLength(2));
      expect(cubit.state.status, SearchStatus.success);
    });

    test('setLocale is a no-op when the language did not change', () async {
      await cubit.init(cityId: _cityId);
      repository.resetRecording();

      await cubit.setLocale('en');

      expect(repository.lastAreaLang, isNull);
    });

    test('init emits empty when the search returns no reports', () async {
      final emptyCubit = SearchCubit(
        getCityById: GetCityByIdUseCase(repository),
        searchReports: SearchReportsUseCase(
          FakeExploreRepository(reports: const []),
        ),
        getCategories: GetCategoriesUseCase(repository),
        getCityAreas: GetCityAreasUseCase(repository),
      );
      addTearDown(emptyCubit.close);

      await emptyCubit.init(cityId: _cityId);

      expect(emptyCubit.state.status, SearchStatus.empty);
      expect(emptyCubit.state.results, isEmpty);
    });

    test('init emits failure when the repository throws', () async {
      repository.shouldFail = true;

      await cubit.init(cityId: _cityId);

      expect(cubit.state.status, SearchStatus.failure);
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.cityId, _cityId);
    });

    test('onQueryChanged debounces before searching', () async {
      await cubit.init(cityId: _cityId);
      repository.resetRecording();

      cubit.onQueryChanged('w');
      cubit.onQueryChanged('wallet');

      expect(repository.searchCalls, 0);
      expect(cubit.state.query, 'wallet');

      await Future<void>.delayed(
        AppDurations.searchDebounce + const Duration(milliseconds: 150),
      );

      expect(repository.searchCalls, 1);
      expect(repository.lastQuery, 'wallet');
      expect(cubit.state.results, hasLength(1));
      expect(cubit.state.status, SearchStatus.success);
    });

    test('applyFilters stores every filter and searches with it', () async {
      await cubit.init(cityId: _cityId);
      repository.resetRecording();

      await cubit.applyFilters(
        type: ReportType.lost,
        categoryIds: const ['cat-electronics'],
        areaIds: const ['area-zamalek'],
        dateFrom: '2026-11-01',
        dateTo: '2026-11-07',
      );

      expect(cubit.state.type, ReportType.lost);
      expect(cubit.state.categoryIds, ['cat-electronics']);
      expect(cubit.state.areaIds, ['area-zamalek']);
      expect(cubit.state.dateFrom, '2026-11-01');
      expect(cubit.state.dateTo, '2026-11-07');
      expect(cubit.state.cityId, _cityId);

      expect(repository.searchCalls, 1);
      expect(repository.lastType, ReportType.lost);
      expect(repository.lastCategoryIds, ['cat-electronics']);
      expect(repository.lastAreaIds, ['area-zamalek']);
      expect(repository.lastDateFrom, '2026-11-01');
      expect(repository.lastDateTo, '2026-11-07');
      expect(cubit.state.results, hasLength(1));
    });

    test('a failure while filtering keeps the city for Retry', () async {
      await cubit.init(cityId: _cityId);

      repository.shouldFail = true;
      await cubit.applyFilters(categoryIds: const ['cat-bags']);

      expect(cubit.state.status, SearchStatus.failure);
      expect(cubit.state.results, isEmpty);
      expect(cubit.state.cityId, _cityId);

      repository.shouldFail = false;
      await cubit.search();

      expect(cubit.state.status, SearchStatus.success);
      expect(cubit.state.results, hasLength(1));
    });

    test('removing chips updates the filters and searches again', () async {
      await cubit.init(cityId: _cityId);
      await cubit.applyFilters(
        type: ReportType.lost,
        categoryIds: const ['cat-electronics'],
        areaIds: const ['area-zamalek'],
        dateFrom: '2026-11-01',
      );

      repository.resetRecording();
      await cubit.removeCategoryFilter('cat-electronics');
      expect(cubit.state.categoryIds, isEmpty);
      expect(repository.searchCalls, 1);

      repository.resetRecording();
      await cubit.removeAreaFilter('area-zamalek');
      expect(cubit.state.areaIds, isEmpty);
      expect(repository.searchCalls, 1);

      repository.resetRecording();
      await cubit.clearDateFilter();
      expect(cubit.state.dateFrom, isNull);
      expect(cubit.state.dateTo, isNull);
      expect(repository.searchCalls, 1);

      repository.resetRecording();
      await cubit.clearTypeFilter();
      expect(cubit.state.type, isNull);
      expect(repository.searchCalls, 1);
    });

    test(
      'resetFilters clears the query and all filters then searches',
      () async {
        await cubit.init(cityId: _cityId);
        cubit.onQueryChanged('airpods');
        await Future<void>.delayed(
          AppDurations.searchDebounce + const Duration(milliseconds: 150),
        );
        await cubit.applyFilters(
          type: ReportType.lost,
          categoryIds: const ['cat-electronics'],
          areaIds: const ['area-zamalek'],
          dateFrom: '2026-11-01',
        );

        repository.resetRecording();
        await cubit.resetFilters();

        expect(cubit.state.query, isEmpty);
        expect(cubit.state.type, isNull);
        expect(cubit.state.categoryIds, isEmpty);
        expect(cubit.state.areaIds, isEmpty);
        expect(cubit.state.dateFrom, isNull);
        expect(cubit.state.dateTo, isNull);
        expect(cubit.state.cityId, _cityId);
        expect(repository.searchCalls, 1);
        expect(repository.lastQuery, isEmpty);
        expect(repository.lastType, isNull);
        expect(cubit.state.status, SearchStatus.success);
      },
    );

    test('search does nothing before init provides a city', () async {
      await cubit.search();

      expect(repository.searchCalls, 0);
      expect(cubit.state.status, SearchStatus.initial);
    });
  });
}
