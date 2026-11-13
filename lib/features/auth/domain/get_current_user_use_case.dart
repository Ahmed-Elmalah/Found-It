import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.getCurrentUser();
}
