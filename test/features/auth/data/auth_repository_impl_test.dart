import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_repository_impl.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthDataSource implements AuthDataSource {
  _FakeAuthDataSource(this.session, {this.error});
  final bool session;
  final Object? error;
  String? email;
  String? password;
  Map<String, dynamic>? data;

  @override
  bool hasActiveSession() => session;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    this.email = email;
    this.password = password;
    final e = error;
    if (e != null) throw e;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    this.email = email;
    this.password = password;
    this.data = data;
    final e = error;
    if (e != null) throw e;
  }
}

void main() {
  test('hasActiveSession true when data source has a session', () {
    expect(
      AuthRepositoryImpl(_FakeAuthDataSource(true)).hasActiveSession(),
      isTrue,
    );
  });

  test('hasActiveSession false when data source has no session', () {
    expect(
      AuthRepositoryImpl(_FakeAuthDataSource(false)).hasActiveSession(),
      isFalse,
    );
  });

  group('login', () {
    Future<void> expectFailure(Object error, AuthFailureType type) async {
      final repo = AuthRepositoryImpl(_FakeAuthDataSource(false, error: error));
      await expectLater(
        repo.login(email: 'a@b.com', password: 'pw'),
        throwsA(isA<AuthFailure>().having((f) => f.type, 'type', type)),
      );
    }

    test('success passes email and password to the data source', () async {
      final source = _FakeAuthDataSource(false);
      await AuthRepositoryImpl(source)
          .login(email: 'a@b.com', password: 'secret');
      expect(source.email, 'a@b.com');
      expect(source.password, 'secret');
    });

    test('invalid_credentials code -> invalidCredentials', () {
      return expectFailure(
        const AuthApiException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
        AuthFailureType.invalidCredentials,
      );
    });

    test('400 with legacy message and no code -> invalidCredentials', () {
      return expectFailure(
        const AuthApiException('Invalid login credentials', statusCode: '400'),
        AuthFailureType.invalidCredentials,
      );
    });

    test('AuthRetryableFetchException -> network', () {
      return expectFailure(
        AuthRetryableFetchException(),
        AuthFailureType.network,
      );
    });

    test('TimeoutException -> network', () {
      return expectFailure(TimeoutException('x'), AuthFailureType.network);
    });

    test('other AuthApiException -> unknown', () {
      return expectFailure(
        const AuthApiException(
          'boom',
          statusCode: '500',
          code: 'unexpected_failure',
        ),
        AuthFailureType.unknown,
      );
    });

    test('generic exception -> unknown', () {
      return expectFailure(Exception('x'), AuthFailureType.unknown);
    });
  });

  group('signUp', () {
    const params = SignUpParams(
      fullName: 'Ahmed Ali',
      email: 'a@b.com',
      phone: '+201012345678',
      address: 'Cairo',
      password: 'secret123',
    );

    Future<void> expectFailure(Object error, AuthFailureType type) async {
      final repo = AuthRepositoryImpl(_FakeAuthDataSource(false, error: error));
      await expectLater(
        repo.signUp(params),
        throwsA(isA<AuthFailure>().having((f) => f.type, 'type', type)),
      );
    }

    test('success passes email, password and profile data', () async {
      final source = _FakeAuthDataSource(false);
      await AuthRepositoryImpl(source).signUp(params);
      expect(source.email, 'a@b.com');
      expect(source.password, 'secret123');
      expect(source.data, {
        'full_name': 'Ahmed Ali',
        'phone': '+201012345678',
        'address': 'Cairo',
      });
    });

    test('address key is absent when address is null', () async {
      final source = _FakeAuthDataSource(false);
      await AuthRepositoryImpl(source).signUp(
        const SignUpParams(
          fullName: 'Ahmed Ali',
          email: 'a@b.com',
          phone: '+201012345678',
          password: 'secret123',
        ),
      );
      expect(source.data, {'full_name': 'Ahmed Ali', 'phone': '+201012345678'});
    });

    test('user_already_exists code -> emailAlreadyInUse', () {
      return expectFailure(
        const AuthApiException(
          'exists',
          statusCode: '422',
          code: 'user_already_exists',
        ),
        AuthFailureType.emailAlreadyInUse,
      );
    });

    test('email_exists code -> emailAlreadyInUse', () {
      return expectFailure(
        const AuthApiException(
          'exists',
          statusCode: '422',
          code: 'email_exists',
        ),
        AuthFailureType.emailAlreadyInUse,
      );
    });

    test('legacy 422 already registered message -> emailAlreadyInUse', () {
      return expectFailure(
        const AuthApiException('User already registered', statusCode: '422'),
        AuthFailureType.emailAlreadyInUse,
      );
    });

    test('AuthWeakPasswordException -> weakPassword', () {
      return expectFailure(
        AuthWeakPasswordException(
          message: 'weak',
          statusCode: '422',
          reasons: const ['length'],
        ),
        AuthFailureType.weakPassword,
      );
    });

    test('weak_password code -> weakPassword', () {
      return expectFailure(
        const AuthApiException(
          'weak',
          statusCode: '422',
          code: 'weak_password',
        ),
        AuthFailureType.weakPassword,
      );
    });

    test('AuthRetryableFetchException -> network', () {
      return expectFailure(
        AuthRetryableFetchException(),
        AuthFailureType.network,
      );
    });

    test('other errors -> unknown', () async {
      await expectFailure(
        const AuthApiException('boom', statusCode: '500', code: 'x'),
        AuthFailureType.unknown,
      );
      await expectFailure(Exception('x'), AuthFailureType.unknown);
    });
  });
}
