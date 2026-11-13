import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/city/data/city_local_data_source.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/home/domain/entities/home_failure.dart';
import 'package:found_it/features/home/domain/entities/home_report_item.dart';
import 'package:found_it/features/home/domain/repositories/home_repository.dart';
import 'package:found_it/features/home/domain/use_cases/get_home_feed_use_case.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/home/view/cubit/home_state.dart';

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
    if (errorToThrow != null) throw errorToThrow!;
    return reportsToReturn;
  }
}

class _FakeCityLocalDataSource implements CityLocalDataSource {
  String? savedCityId;

  @override
  String? getSelectedCityId() => savedCityId;

  @override
  Future<void> saveSelectedCityId(String cityId) async {
    savedCityId = cityId;
  }

  @override
  Future<void> clearSelectedCityId() async {
    savedCityId = null;
  }
}

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = const [
    CityEntity(id: 'cairo-uuid', nameEn: 'Cairo', nameAr: 'القاهرة'),
    CityEntity(id: 'alex-uuid', nameEn: 'Alexandria', nameAr: 'الإسكندرية'),
  ];

  @override
  Future<List<CityEntity>> getCities() async => cities;

  @override
  Future<void> selectCity(String cityId) async {}
}

void main() {
  group('HomeCubit', () {
    late _FakeHomeRepository homeRepo;
    late _FakeCityLocalDataSource cityLocalDataSource;
    late _FakeCityRepository cityRepo;
    late GetHomeFeedUseCase getHomeFeedUseCase;
    late GetCitiesUseCase getCitiesUseCase;
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
      cityLocalDataSource = _FakeCityLocalDataSource();
      cityRepo = _FakeCityRepository();
      getHomeFeedUseCase = GetHomeFeedUseCase(homeRepo);
      getCitiesUseCase = GetCitiesUseCase(cityRepo);

      cubit = HomeCubit(
        getHomeFeedUseCase: getHomeFeedUseCase,
        cityLocalDataSource: cityLocalDataSource,
        getCitiesUseCase: getCitiesUseCase,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default status and Cairo city', () {
      expect(cubit.state.status, HomeStatus.initial);
      expect(cubit.state.selectedCityName, 'Cairo');
      expect(cubit.state.reports, isEmpty);
    });

    test('init loads cities, resolves selected city and fetches feed successfully', () async {
      homeRepo.reportsToReturn = tReports;
      cityLocalDataSource.savedCityId = 'cairo-uuid';

      await cubit.init();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.selectedCityId, 'cairo-uuid');
      expect(cubit.state.selectedCityName, 'القاهرة');
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
      expect(cubit.state.errorMessage, 'No internet');
    });

    test('selectCity changes city and reloads feed', () async {
      homeRepo.reportsToReturn = tReports;
      const newCity = CityEntity(id: 'alex-uuid', nameEn: 'Alexandria', nameAr: 'الإسكندرية');

      await cubit.selectCity(newCity, locale: 'ar');

      expect(cubit.state.selectedCityId, 'alex-uuid');
      expect(cubit.state.selectedCityName, 'الإسكندرية');
      expect(cityLocalDataSource.savedCityId, 'alex-uuid');
      expect(cubit.state.status, HomeStatus.success);
    });

    test('refresh calls feed again with current city', () async {
      homeRepo.reportsToReturn = tReports;
      await cubit.init();

      await cubit.refresh();

      expect(cubit.state.status, HomeStatus.success);
      expect(cubit.state.reports, tReports);
    });
  });
}
