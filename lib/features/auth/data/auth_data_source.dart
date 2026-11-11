import 'package:supabase_flutter/supabase_flutter.dart';

// Login, sign up and logout are added in stage 8.
abstract interface class AuthDataSource {
  bool hasActiveSession();
}

class AuthDataSourceImpl implements AuthDataSource {
  const AuthDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  bool hasActiveSession() => _client.auth.currentSession != null;
}
