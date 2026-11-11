import 'package:found_it/features/auth/domain/auth_repository.dart';

class WatchAuthStateUseCase {
  const WatchAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  Stream<bool> call() => _repository.authStateChanges();
}
