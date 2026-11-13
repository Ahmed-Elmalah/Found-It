import 'package:found_it/features/profile/domain/entities/city_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class GetActiveCitiesUseCase {
  const GetActiveCitiesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<List<CityEntity>> call() => _repository.getActiveCities();
}
