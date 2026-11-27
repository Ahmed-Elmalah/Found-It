import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:found_it/features/home/domain/entities/home_report_item.dart';
import 'package:found_it/features/home/domain/repositories/home_repository.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';

class _FakeMatchesRepo implements MatchesRepository {
  int count = 0;
  @override
  Future<int> getMyMatchesCount() async => count;
  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async => const [];
  @override
  Future<MatchEntity> getMatchDetails(String matchId) => throw UnimplementedError();
  @override
  Future<void> rejectMatch(String matchId) => throw UnimplementedError();
}

class _FakeHomeRepository implements HomeRepository {
  List<HomeReportItem> reportsToReturn = const [];
  Object? errorToThrow;

  @override
  Future<List<HomeReportItem>> getHomeFeed({
    required String cityId,
    String? type = 'found',
    int limit = 20,
    int offset = 0,
  }) async {
    final e = errorToThrow;
    if (e != null) throw e;
    return reportsToReturn;
  }
}

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = const [
    CityEntity(id: 'cairo-uuid', nameEn: 'Cairo', nameAr: 'القاهرة'),
    CityEntity(id: 'alex-uuid', nameEn: 'Alexandria', nameAr: 'الإسكندرية'),
  ];
  String? selectedCityId;

  @override
  Future<List<CityEntity>> getCities() async => cities;

  @override
  Future<void> selectCity(String cityId) async {
    selectedCityId = cityId;
  }
}

void main() {
  group('HomeCubit', () {
    late _FakeHomeRepository homeRepo;
    late _FakeCityRepository cityRepo;
    late GetHomeFeedUseCase getHomeFeedUseCase;
    late GetCitiesUseCase getCitiesUseCase;
    late SelectCityUseCase selectCityUseCase;
    late HomeCubit cubit;

    final tReports = [
      HomeReportItem(
        id: 'rep-1',
        refCode: 'RPT-1',
        title: 'Found Wallet',
        type: 'found',
        categoryName: 'Wallets',
        categoryIcon: 'wallet',
        areaName: 'Maadi',
        cityName: 'Cairo',
        itemDate: DateTime.now(),
        images: const [],
        status: 'active',
        isMine: false,
        createdAt: DateTime.now(),
      ),
    ];

    setUp(() {
      homeRepo = _FakeHomeRepository();
      cityRepo = _FakeCityRepository();
      getHomeFeedUseCase = GetHomeFeedUseCase(homeRepo);
      getCitiesUseCase = GetCitiesUseCase(cityRepo);
      selectCityUseCase = SelectCityUseCase(cityRepo);

      cubit = HomeCubit(
        getHomeFeedUseCase: getHomeFeedUseCase,
        getCitiesUseCase: getCitiesUseCase,
        selectCityUseCase: selectCityUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default status and empty city', () {
      expect(cubit.state.status, HomeStatus.initial);
      expect(cubit.state.selectedCityId, '');
      expect(cubit.state.selectedCity, isNull);
      expect(cubit.state.reports, isEmpty);
    });

    test('init loads cities, resolves selected city and fetches feed successfully', () async {
      homeRepo.reportsToReturn = tReports;

      await cubit.init(initialCityId: 'cairo-uuid');

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.selectedCityId, 'cairo-uuid');
      expect(cubit.state.selectedCity?.nameEn, 'Cairo');
      expect(cubit.state.reports, tReports);
      expect(cubit.state.isEmpty, isFalse);
    });

    test('init emits success with empty list when no reports exist in city', () async {
      homeRepo.reportsToReturn = const [];

      await cubit.init();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.reports, isEmpty);
      expect(cubit.state.isEmpty, isTrue);
    });

    test('init emits failure when feed fetch fails', () async {
      homeRepo.errorToThrow = const HomeFailure(HomeFailureType.network, 'No internet');

      await cubit.init();

      expect(cubit.state.status, HomeStatus.failure);
      expect(cubit.state.failure, const HomeFailure(HomeFailureType.network, 'No internet'));
    });

    test('selectCity changes city and reloads feed', () async {
      homeRepo.reportsToReturn = tReports;
      const newCity = CityEntity(id: 'alex-uuid', nameEn: 'Alexandria', nameAr: 'الإسكندرية');
      String? syncedCityId;

      await cubit.selectCity(
        newCity,
        onCitySyncedToAuth: (id) => syncedCityId = id,
      );

      expect(cubit.state.selectedCityId, 'alex-uuid');
      expect(cubit.state.selectedCity, newCity);
      expect(cityRepo.selectedCityId, 'alex-uuid');
      expect(syncedCityId, 'alex-uuid');
      expect(cubit.state.status, HomeStatus.success);
    });

    test('onCityChangedFromAuth updates city and reloads feed', () async {
      homeRepo.reportsToReturn = tReports;
      await cubit.init();

      await cubit.onCityChangedFromAuth('alex-uuid');

      expect(cubit.state.selectedCityId, 'alex-uuid');
      expect(cubit.state.selectedCity?.id, 'alex-uuid');
      expect(cubit.state.status, HomeStatus.success);
    });

    test('refresh calls feed again with current city', () async {
      homeRepo.reportsToReturn = tReports;
      await cubit.init();

      await cubit.refresh();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.reports, tReports);
    });

    test('reportsChangedNotifier notify triggers reload', () async {
      final notifier = ReportsChangedNotifier();
      homeRepo.reportsToReturn = tReports;
      final cubitWithNotifier = HomeCubit(
        getHomeFeedUseCase: getHomeFeedUseCase,
        getCitiesUseCase: getCitiesUseCase,
        selectCityUseCase: selectCityUseCase,
        reportsChangedNotifier: notifier,
      );
      await cubitWithNotifier.init(initialCityId: 'cairo-uuid');

      final newReports = [
        HomeReportItem(
          id: 'rep-2',
          refCode: 'RPT-2',
          title: 'Second Report',
          type: 'found',
          categoryName: 'Wallets',
          categoryIcon: 'wallet',
          areaName: 'Maadi',
          cityName: 'Cairo',
          itemDate: DateTime.now(),
          images: const [],
          status: 'active',
          isMine: false,
          createdAt: DateTime.now(),
        ),
      ];
      homeRepo.reportsToReturn = newReports;

      notifier.notify();
      await pumpEventQueue();

      expect(cubitWithNotifier.state.reports, newReports);
      await cubitWithNotifier.close();
      notifier.dispose();
    });

    test('init fetches potentialMatchesCount when getMyMatchesCountUseCase is provided', () async {
      final matchesRepo = _FakeMatchesRepo()..count = 3;
      final cubitWithMatches = HomeCubit(
        getHomeFeedUseCase: GetHomeFeedUseCase(homeRepo),
        getCitiesUseCase: GetCitiesUseCase(cityRepo),
        selectCityUseCase: SelectCityUseCase(cityRepo),
        getMyMatchesCountUseCase: GetMyMatchesCountUseCase(matchesRepo),
      );
      addTearDown(cubitWithMatches.close);

      await cubitWithMatches.init(initialCityId: 'cairo-uuid');

      expect(cubitWithMatches.state.status, HomeStatus.success);
      expect(cubitWithMatches.state.potentialMatchesCount, 3);
    });
  });
}
