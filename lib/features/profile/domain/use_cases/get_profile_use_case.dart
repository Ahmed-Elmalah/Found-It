import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfileEntity> call() => _repository.getMyProfile();
}
