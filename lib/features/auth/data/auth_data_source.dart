import 'package:supabase_flutter/supabase_flutter.dart';

// Sign up and logout are added in a later stage.
abstract interface class AuthDataSource {
  bool hasActiveSession();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });
}

class AuthDataSourceImpl implements AuthDataSource {
  const AuthDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  bool hasActiveSession() => _client.auth.currentSession != null;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }
}
