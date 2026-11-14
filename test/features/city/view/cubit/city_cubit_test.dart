import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';
import 'package:found_it/features/city/view/cubit/city_cubit.dart';

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = [];
  String? selectedCityId;
  Object? getCitiesError;
  Object? selectCityError;

  @override
  Future<List<CityEntity>> getCities() async {
    final e = getCitiesError;
    if (e != null) throw e;
    return cities;
  }

  @override
  Future<void> selectCity(String cityId) async {
    final e = selectCityError;
    if (e != null) throw e;
    selectedCityId = cityId;
  }
}

void main() {
  late _FakeCityRepository repo;
  late CityCubit cubit;

  const testCities = [
    CityEntity(id: 'c1', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
    CityEntity(id: 'c2', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 2),
  ];

  setUp(() {
    repo = _FakeCityRepository()..cities = testCities;
    cubit = CityCubit(
      getCitiesUseCase: GetCitiesUseCase(repo),
      selectCityUseCase: SelectCityUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  group('CityCubit.loadCities', () {
    test('emits loading and loaded with cities on success', () async {
      expectLater(
        cubit.stream,
        emitsInOrder([
          const CityState(status: CityStatus.loading),
          const CityState(status: CityStatus.loaded, cities: testCities),
        ]),
      );

      await cubit.loadCities();
    });

    test('emits loading and failure on error', () async {
      repo.getCitiesError = Exception('Network error');

      expectLater(
        cubit.stream,
        emitsInOrder([
          const CityState(status: CityStatus.loading),
          predicate<CityState>((s) => s.status == CityStatus.failure && s.errorMessage != null),
        ]),
      );

      await cubit.loadCities();
    });
  });

  group('CityCubit.selectCity', () {
    test('updates selectedCityId and resets hasLocationRequiredError', () {
      cubit.selectCity('c1');
      expect(cubit.state.selectedCityId, 'c1');
      expect(cubit.state.hasLocationRequiredError, false);
    });
  });

  group('CityCubit.submit', () {
    test('emits hasLocationRequiredError when no city is selected', () async {
      await cubit.submit();

      expect(cubit.state.hasLocationRequiredError, true);
      expect(cubit.state.status, CityStatus.initial);
      expect(repo.selectedCityId, isNull);
    });

    test('emits submitting and success when city is selected', () async {
      cubit.selectCity('c1');

      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<CityState>((s) => s.status == CityStatus.submitting),
          predicate<CityState>((s) => s.status == CityStatus.success),
        ]),
      );

      await cubit.submit();

      expect(repo.selectedCityId, 'c1');
    });

    test('emits submitting and failure when selection fails on repository', () async {
      repo.selectCityError = Exception('RPC failed');
      cubit.selectCity('c1');

      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<CityState>((s) => s.status == CityStatus.submitting),
          predicate<CityState>((s) => s.status == CityStatus.failure && s.errorMessage != null),
        ]),
      );

      await cubit.submit();
    });
  });
}
