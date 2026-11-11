import 'package:found_it/features/auth/domain/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.login(email: email.trim(), password: password);
}
