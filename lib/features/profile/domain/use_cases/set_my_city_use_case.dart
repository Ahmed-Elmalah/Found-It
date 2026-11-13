import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class SetMyCityUseCase {
  const SetMyCityUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(String cityId) => _repository.setMyCity(cityId);
}
