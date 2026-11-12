import 'dart:async';

import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_model.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  bool hasActiveSession() => _dataSource.hasActiveSession();

  @override
  Stream<bool> authStateChanges() => _dataSource.authStateChanges();

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final row = await _dataSource.getMyProfile();
      return row == null ? null : AuthModel.fromJson(row);
    } catch (e) {
      throw AuthFailure(_map(e));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.signOut();
    } catch (e) {
      throw AuthFailure(_map(e));
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      await _dataSource.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw AuthFailure(_map(e));
    }
  }

  @override
  Future<void> signUp(SignUpParams params) async {
    try {
      await _dataSource.signUp(
        email: params.email,
        password: params.password,
        data: {
          'full_name': params.fullName,
          'phone': params.phone,
          if (params.address != null) 'address': params.address,
        },
      );
    } catch (e) {
      throw AuthFailure(_map(e));
    }
  }

  AuthFailureType _map(Object error) {
    if (error is AuthWeakPasswordException) return AuthFailureType.weakPassword;
    if (error is AuthApiException) {
      final message = error.message.toLowerCase();
      if (error.code == 'user_already_exists' ||
          error.code == 'email_exists' ||
          (error.code == null &&
              error.statusCode == '422' &&
              message.contains('already registered'))) {
        return AuthFailureType.emailAlreadyInUse;
      }
      if (error.code == 'weak_password') return AuthFailureType.weakPassword;
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
