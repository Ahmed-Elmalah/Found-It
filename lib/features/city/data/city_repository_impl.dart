import 'package:found_it/features/city/data/city_remote_data_source.dart';
import 'package:found_it/features/city/domain/city_entity.dart';
import 'package:found_it/features/city/domain/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  const CityRepositoryImpl({
    required this.remoteDataSource,
  });

  final CityRemoteDataSource remoteDataSource;

  @override
  Future<List<CityEntity>> getCities() => remoteDataSource.getActiveCities();

  @override
  Future<void> selectCity(String cityId) => remoteDataSource.setMyCity(cityId);
}
