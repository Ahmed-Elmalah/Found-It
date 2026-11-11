import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/data/auth_data_source.dart';
import 'package:found_it/features/auth/data/auth_repository_impl.dart';

class _FakeAuthDataSource implements AuthDataSource {
  _FakeAuthDataSource(this.session);
  final bool session;

  @override
  bool hasActiveSession() => session;
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
}
