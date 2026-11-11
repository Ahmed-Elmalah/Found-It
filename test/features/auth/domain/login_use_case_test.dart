import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/login_use_case.dart';

class _FakeAuthRepository implements AuthRepository {
  // Sign up is not used by this test.
  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();

  String? email;
  String? password;
  Object? error;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) async {
    this.email = email;
    this.password = password;
    final e = error;
    if (e != null) throw e;
  }
}

void main() {
  test('trims the email but not the password', () async {
    final repo = _FakeAuthRepository();
    await LoginUseCase(repo)
        .call(email: '  a@b.com  ', password: '  pw with spaces ');
    expect(repo.email, 'a@b.com');
    expect(repo.password, '  pw with spaces ');
  });

  test('passes AuthFailure through', () async {
    final repo = _FakeAuthRepository()
      ..error = const AuthFailure(AuthFailureType.network);
    await expectLater(
      LoginUseCase(repo).call(email: 'a@b.com', password: 'pw'),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.type,
          'type',
          AuthFailureType.network,
        ),
      ),
    );
  });
}
