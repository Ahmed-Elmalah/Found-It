import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/city/data/city_model.dart';
import 'package:found_it/features/city/data/city_remote_data_source.dart';
import 'package:found_it/features/city/data/city_repository_impl.dart';

class _FakeCityRemoteDataSource implements CityRemoteDataSource {
  List<CityModel> activeCities = [];
  String? lastSetCityId;
  Object? error;

  @override
  Future<List<CityModel>> getActiveCities() async {
    final e = error;
    if (e != null) throw e;
    return activeCities;
  }

  @override
  Future<void> setMyCity(String cityId) async {
    final e = error;
    if (e != null) throw e;
    lastSetCityId = cityId;
  }
}

void main() {
  late _FakeCityRemoteDataSource remote;
  late CityRepositoryImpl repository;

  setUp(() {
    remote = _FakeCityRemoteDataSource();
    repository = CityRepositoryImpl(
      remoteDataSource: remote,
    );
  });

  group('CityRepositoryImpl.getCities', () {
    test('returns active cities from remote data source', () async {
      remote.activeCities = const [
        CityModel(id: 'c1', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
      ];

      final result = await repository.getCities();

      expect(result.length, 1);
      expect(result.first.nameEn, 'Cairo');
    });

    test('rethrows error when remote fails', () async {
      remote.error = Exception('Network error');

      expect(() => repository.getCities(), throwsA(isA<Exception>()));
    });
  });

  group('CityRepositoryImpl.selectCity', () {
    test('updates remote data source with selected cityId', () async {
      await repository.selectCity('c1');

      expect(remote.lastSetCityId, 'c1');
    });

    test('rethrows error when remote fails', () async {
      remote.error = Exception('Server RPC failed');

      await expectLater(
        () => repository.selectCity('c1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
