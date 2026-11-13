import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';

const _withCity = UserEntity(
  id: 'u1',
  email: 'a@b.com',
  fullName: 'Ahmed',
  cityId: 'c1',
);
const _noCity = UserEntity(id: 'u1', email: 'a@b.com', fullName: 'Ahmed');

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session = false, this.user});

  bool session;
  UserEntity? user;
  Object? profileError;
  Object? logoutError;
  int logoutCalls = 0;
  int listenCount = 0;
  late final controller = StreamController<bool>.broadcast(
    onListen: () => listenCount++,
  );

  @override
  bool hasActiveSession() => session;

  @override
  Stream<bool> authStateChanges() => controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final e = profileError;
    if (e != null) throw e;
    return user;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    final e = logoutError;
    if (e != null) throw e;
  }

  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();
}

AuthCubit _cubit(_FakeAuthRepository repo) => AuthCubit(
  watchAuthState: WatchAuthStateUseCase(repo),
  getCurrentUser: GetCurrentUserUseCase(repo),
  logout: LogoutUseCase(repo),
  hasActiveSession: HasActiveSessionUseCase(repo),
);

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  test('starts unknown', () async {
    final cubit = _cubit(_FakeAuthRepository());
    expect(cubit.state.status, AuthStatus.unknown);
    expect(cubit.state.isLoggedIn, isNull);
    expect(cubit.state.hasCity, isNull);
    await cubit.close();
  });

  test('no session -> unauthenticated', () async {
    final cubit = _cubit(_FakeAuthRepository());
    await cubit.start();
    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.isLoggedIn, isFalse);
    expect(cubit.state.hasCity, isNull);
    await cubit.close();
  });

  test('session + user with city -> authenticated, hasCity true', () async {
    final cubit = _cubit(_FakeAuthRepository(session: true, user: _withCity));
    await cubit.start();
    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, _withCity);
    expect(cubit.state.isLoggedIn, isTrue);
    expect(cubit.state.hasCity, isTrue);
    await cubit.close();
  });

  test('user without city -> hasCity false', () async {
    final cubit = _cubit(_FakeAuthRepository(session: true, user: _noCity));
    await cubit.start();
    expect(cubit.state.isLoggedIn, isTrue);
    expect(cubit.state.hasCity, isFalse);
    await cubit.close();
  });

  test(
    'profile load fails -> authenticated, user null, hasCity null',
    () async {
      final repo = _FakeAuthRepository(session: true)
        ..profileError = const AuthFailure(AuthFailureType.network);
      final cubit = _cubit(repo);
      await cubit.start();
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, isNull);
      expect(cubit.state.hasCity, isNull);
      await cubit.close();
    },
  );

  test('emits only the final state once per load', () async {
    final cubit = _cubit(_FakeAuthRepository(session: true, user: _withCity));
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.start();
    await _pump();
    expect(states, [
      const AuthState(status: AuthStatus.authenticated, user: _withCity),
    ]);
    await sub.cancel();
    await cubit.close();
  });

  test('stream false -> unauthenticated', () async {
    final repo = _FakeAuthRepository(session: true, user: _withCity);
    final cubit = _cubit(repo);
    await cubit.start();
    repo.controller.add(false);
    await _pump();
    expect(cubit.state, const AuthState(status: AuthStatus.unauthenticated));
    await cubit.close();
  });

  test('stream true -> loads the user', () async {
    final repo = _FakeAuthRepository();
    final cubit = _cubit(repo);
    await cubit.start();
    repo
      ..user = _noCity
      ..controller.add(true);
    await _pump();
    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, _noCity);
    await cubit.close();
  });

  test('logout -> unauthenticated', () async {
    final repo = _FakeAuthRepository(session: true, user: _withCity);
    final cubit = _cubit(repo);
    await cubit.start();
    await cubit.logout();
    expect(repo.logoutCalls, 1);
    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.user, isNull);
    await cubit.close();
  });

  test('logout failure rethrows and keeps the state', () async {
    final repo = _FakeAuthRepository(session: true, user: _withCity)
      ..logoutError = const AuthFailure(AuthFailureType.network);
    final cubit = _cubit(repo);
    await cubit.start();
    await expectLater(cubit.logout(), throwsA(isA<AuthFailure>()));
    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, _withCity);
    await cubit.close();
  });

  test('cityChanged updates hasCity', () async {
    final cubit = _cubit(_FakeAuthRepository(session: true, user: _noCity));
    await cubit.start();
    cubit.cityChanged('c9');
    expect(cubit.state.user?.cityId, 'c9');
    expect(cubit.state.hasCity, isTrue);
    await cubit.close();
  });

  test('cityChanged does nothing without a loaded user', () async {
    final cubit = _cubit(_FakeAuthRepository());
    await cubit.start();
    cubit.cityChanged('c9');
    expect(cubit.state, const AuthState(status: AuthStatus.unauthenticated));
    await cubit.close();
  });

  test('start() twice subscribes once', () async {
    final repo = _FakeAuthRepository();
    final cubit = _cubit(repo);
    await cubit.start();
    await cubit.start();
    expect(repo.listenCount, 1);
    await cubit.close();
  });

  test('close cancels the subscription (no emit after close)', () async {
    final repo = _FakeAuthRepository(session: true, user: _withCity);
    final cubit = _cubit(repo);
    await cubit.start();
    await cubit.close();
    expect(repo.controller.hasListener, isFalse);
    repo.controller.add(false);
    await _pump();
    expect(cubit.state.status, AuthStatus.authenticated);
  });
}
