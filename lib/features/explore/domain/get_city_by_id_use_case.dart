import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';

class GetCityByIdUseCase {
  const GetCityByIdUseCase(this._repository);

  final ExploreRepository _repository;

  Future<CityEntity> call(String cityId) => _repository.getCityById(cityId);
}
