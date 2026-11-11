import 'dart:async';

import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  bool hasActiveSession() => _dataSource.hasActiveSession();

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _dataSource.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw AuthFailure(_map(e));
    }
  }

  AuthFailureType _map(Object error) {
    if (error is AuthApiException) {
      final isInvalid =
          error.code == 'invalid_credentials' ||
          (error.statusCode == '400' &&
              error.message.toLowerCase().contains(
                'invalid login credentials',
              ));
      return isInvalid
          ? AuthFailureType.invalidCredentials
          : AuthFailureType.unknown;
    }
    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return AuthFailureType.network;
    }
    if (error is AuthException) return AuthFailureType.unknown;
    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return AuthFailureType.network;
    }
    return AuthFailureType.unknown;
  }
}
