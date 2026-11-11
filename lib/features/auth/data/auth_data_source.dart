import 'package:supabase_flutter/supabase_flutter.dart';

// Logout is added in a later stage.
abstract interface class AuthDataSource {
  bool hasActiveSession();

  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  /// [data] is stored as user metadata; a database trigger builds the profile.
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
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

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
    // With email confirmation on, Supabase hides an existing email by
    // returning a user without identities instead of throwing.
    final identities = response.user?.identities;
    if (identities != null && identities.isEmpty) {
      throw const AuthApiException(
        'User already registered',
        statusCode: '422',
        code: 'user_already_exists',
      );
    }
  }
}
