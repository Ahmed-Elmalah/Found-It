import 'auth_repository.dart';

class HasActiveSessionUseCase {
  const HasActiveSessionUseCase(this._repository);

  final AuthRepository _repository;

  bool call() => _repository.hasActiveSession();
}
