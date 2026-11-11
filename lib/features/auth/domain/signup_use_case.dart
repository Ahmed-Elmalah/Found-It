import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(SignUpParams params) {
    final address = params.address?.trim();
    return _repository.signUp(
      SignUpParams(
        fullName: params.fullName.trim(),
        email: params.email.trim(),
        phone: params.phone,
        address: (address == null || address.isEmpty) ? null : address,
        password: params.password,
      ),
    );
  }
}
