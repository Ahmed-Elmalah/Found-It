import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';

const _user = UserEntity(id: 'u1', email: 'a@b.com', fullName: 'Ahmed');

class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Stream<bool> authStateChanges() => Stream<bool>.fromIterable([true, false]);

  @override
  Future<UserEntity?> getCurrentUser() async => _user;

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  bool hasActiveSession() => true;

  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();
}

void main() {
  test('WatchAuthStateUseCase forwards the repository stream', () {
    final repo = _FakeAuthRepository();
    expect(WatchAuthStateUseCase(repo)(), emitsInOrder([true, false]));
  });

  test('GetCurrentUserUseCase returns the repository user', () async {
    expect(await GetCurrentUserUseCase(_FakeAuthRepository())(), _user);
  });

  test('LogoutUseCase calls the repository', () async {
    final repo = _FakeAuthRepository();
    await LogoutUseCase(repo)();
    expect(repo.logoutCalls, 1);
  });
}
