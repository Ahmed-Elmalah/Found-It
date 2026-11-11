import 'package:found_it/features/auth/domain/sign_up_params.dart';

// Logout is added in a later stage.
abstract interface class AuthRepository {
  bool hasActiveSession();

  /// Signs in with email and password.
  ///
  /// Throws [AuthFailure] when the sign in fails.
  Future<void> login({required String email, required String password});

  /// Creates a new account with the given profile data.
  ///
  /// Throws [AuthFailure] when the sign up fails.
  Future<void> signUp(SignUpParams params);
}
