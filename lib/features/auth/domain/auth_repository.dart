import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';

abstract interface class AuthRepository {
  bool hasActiveSession();

  /// Emits `true` when a user is signed in and `false` when signed out,
  /// on every change (login, logout, session expiry).
  Stream<bool> authStateChanges();

  /// The signed in user's profile, or null when nobody is logged in.
  ///
  /// Throws [AuthFailure] (network / unknown) on errors.
  Future<UserEntity?> getCurrentUser();

  /// Signs in with email and password.
  ///
  /// Throws [AuthFailure] when the sign in fails.
  Future<void> login({required String email, required String password});

  /// Creates a new account with the given profile data.
  ///
  /// Throws [AuthFailure] when the sign up fails.
  Future<void> signUp(SignUpParams params);

  /// Signs the current user out.
  ///
  /// Throws [AuthFailure] when the sign out fails.
  Future<void> logout();
}
