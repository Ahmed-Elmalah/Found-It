import 'package:found_it/features/city/domain/entities/city_entity.dart';
import 'package:found_it/features/city/domain/repositories/city_repository.dart';

class GetCitiesUseCase {
  const GetCitiesUseCase(this._repository);

  final CityRepository _repository;

  Future<List<CityEntity>> call() => _repository.getCities();
}
