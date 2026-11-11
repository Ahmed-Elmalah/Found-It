// Sign up and logout are added in a later stage.
abstract interface class AuthRepository {
  bool hasActiveSession();

  /// Signs in with email and password.
  ///
  /// Throws [AuthFailure] when the sign in fails.
  Future<void> login({required String email, required String password});
}
