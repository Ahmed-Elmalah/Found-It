import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_repository_impl.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthDataSource implements AuthDataSource {
  _FakeAuthDataSource(this.session, {this.error});
  final bool session;
  final Object? error;
  String? email;
  String? password;

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
}
