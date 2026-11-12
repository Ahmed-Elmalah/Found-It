import 'package:found_it/features/profile/domain/repositories/profile_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call() => _repository.logout();
}
