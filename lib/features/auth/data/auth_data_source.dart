import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthDataSource {
  bool hasActiveSession();

  /// `true` while a session exists; emits on every auth change.
  Stream<bool> authStateChanges();

  /// The current user's profile row, or null without a session / row.
  Future<Map<String, dynamic>?> getMyProfile();

  Future<void> signOut();

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
  Stream<bool> authStateChanges() => _client.auth.onAuthStateChange
      .map((event) => event.session != null)
      .distinct();

  @override
  Future<Map<String, dynamic>?> getMyProfile() async {
    if (_client.auth.currentSession == null) return null;
    return _client.rpc('get_my_profile').maybeSingle();
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

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
