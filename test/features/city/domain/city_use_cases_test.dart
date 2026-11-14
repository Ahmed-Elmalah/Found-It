import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';
import 'package:found_it/features/city/domain/get_cities_use_case.dart';
import 'package:found_it/features/city/domain/select_city_use_case.dart';

class _FakeCityRepository implements CityRepository {
  List<CityEntity> cities = [];
  String? selectedCityId;
  Object? error;

  @override
  Future<List<CityEntity>> getCities() async {
    final e = error;
    if (e != null) throw e;
    return cities;
  }

  @override
  Future<void> selectCity(String cityId) async {
    final e = error;
    if (e != null) throw e;
    selectedCityId = cityId;
  }
}

void main() {
  group('CityEntity', () {
    const city = CityEntity(
      id: 'c1',
      nameEn: 'Cairo',
      nameAr: 'القاهرة',
      sortOrder: 1,
    );

    test('returns Arabic name when languageCode is ar', () {
      expect(city.localizedName('ar'), 'القاهرة');
    });

    test('returns English name when languageCode is en', () {
      expect(city.localizedName('en'), 'Cairo');
    });
  });

  group('GetCitiesUseCase', () {
    test('delegates call to repository getCities', () async {
      final repo = _FakeCityRepository()
        ..cities = const [
          CityEntity(id: 'c1', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
          CityEntity(id: 'c2', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 2),
        ];

      final useCase = GetCitiesUseCase(repo);
      final result = await useCase();

      expect(result.length, 2);
      expect(result.first.nameEn, 'Cairo');
    });
  });

  group('SelectCityUseCase', () {
    test('delegates call to repository selectCity', () async {
      final repo = _FakeCityRepository();
      final useCase = SelectCityUseCase(repo);

      await useCase('c1');

      expect(repo.selectedCityId, 'c1');
    });
  });
}
