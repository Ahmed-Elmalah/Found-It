import 'package:found_it/features/explore/domain/city_entity.dart';
import 'package:found_it/features/explore/domain/explore_repository.dart';

class GetCurrentCityUseCase {
  const GetCurrentCityUseCase(this._repository);

  final ExploreRepository _repository;

  Future<CityEntity> call() => _repository.getCurrentCity();
}
