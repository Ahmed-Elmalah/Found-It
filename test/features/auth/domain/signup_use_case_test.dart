import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/signup_use_case.dart';

class _FakeAuthRepository implements AuthRepository {
  SignUpParams? received;
  Object? error;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp(SignUpParams params) async {
    received = params;
    final e = error;
    if (e != null) throw e;
  }
}

void main() {
  late _FakeAuthRepository repo;
  late SignUpUseCase useCase;

  setUp(() {
    repo = _FakeAuthRepository();
    useCase = SignUpUseCase(repo);
  });

  test('trims name, email and address; keeps phone and password', () async {
    await useCase(
      const SignUpParams(
        fullName: '  Ahmed Ali ',
        email: ' a@b.com  ',
        phone: '+201012345678',
        address: '  Cairo ',
        password: ' pw ',
      ),
    );
    expect(
      repo.received,
      const SignUpParams(
        fullName: 'Ahmed Ali',
        email: 'a@b.com',
        phone: '+201012345678',
        address: 'Cairo',
        password: ' pw ',
      ),
    );
  });

  test('blank address becomes null', () async {
    await useCase(
      const SignUpParams(
        fullName: 'A',
        email: 'a@b.com',
        phone: '+201012345678',
        address: '   ',
        password: 'pw',
      ),
    );
    expect(repo.received!.address, isNull);
  });

  test('null address stays null', () async {
    await useCase(
      const SignUpParams(
        fullName: 'A',
        email: 'a@b.com',
        phone: '+201012345678',
        password: 'pw',
      ),
    );
    expect(repo.received!.address, isNull);
  });

  test('failures pass through', () async {
    repo.error = const AuthFailure(AuthFailureType.emailAlreadyInUse);
    await expectLater(
      useCase(
        const SignUpParams(
          fullName: 'A',
          email: 'a@b.com',
          phone: '+201012345678',
          password: 'pw',
        ),
      ),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.type,
          'type',
          AuthFailureType.emailAlreadyInUse,
        ),
      ),
    );
  });
}
