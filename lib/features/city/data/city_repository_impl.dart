import 'package:flutter/foundation.dart';

import 'package:found_it/features/city/data/city_local_data_source.dart';
import 'package:found_it/features/city/data/city_remote_data_source.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final CityRemoteDataSource remoteDataSource;
  final CityLocalDataSource localDataSource;

  @override
  Future<List<CityEntity>> getCities() => remoteDataSource.getActiveCities();

  @override
  Future<void> selectCity(String cityId) async {
    // 1. Supabase is the single source of truth
    await remoteDataSource.setMyCity(cityId);

    // 2. Safe local caching: if local storage fails, don't fail the operation
    try {
      await localDataSource.saveSelectedCityId(cityId);
    } catch (e, stackTrace) {
      debugPrint('CityRepositoryImpl: Failed to cache cityId locally: $e\n$stackTrace');
    }
  }
}
