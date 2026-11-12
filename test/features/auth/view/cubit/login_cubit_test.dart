import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/login_use_case.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<bool> authStateChanges() => const Stream.empty();

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  // Sign up is not used by this test.
  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();

  Object? error;
  Completer<void>? gate;
  int calls = 0;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) async {
    calls++;
    await gate?.future;
    final e = error;
    if (e != null) throw e;
  }
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeAuthRepository repo;
  late LoginCubit cubit;
  late List<LoginState> states;
  late StreamSubscription<LoginState> sub;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = LoginCubit(LoginUseCase(repo));
    states = [];
    sub = cubit.stream.listen(states.add);
  });

  tearDown(() async {
    await sub.cancel();
    await cubit.close();
  });

  const submitting = LoginState(status: LoginStatus.submitting);

  test('success emits [submitting, success]', () async {
    await cubit.submit(email: 'a@b.com', password: 'pw');
    await pump();
    expect(states, [submitting, const LoginState(status: LoginStatus.success)]);
  });

  test('invalid credentials emits failure(invalidCredentials)', () async {
    repo.error = const AuthFailure(AuthFailureType.invalidCredentials);
    await cubit.submit(email: 'a@b.com', password: 'pw');
    await pump();
    expect(states, [
      submitting,
      const LoginState(
        status: LoginStatus.failure,
        failure: AuthFailureType.invalidCredentials,
      ),
    ]);
  });

  test('unexpected error emits failure(unknown)', () async {
    repo.error = StateError('boom');
    await cubit.submit(email: 'a@b.com', password: 'pw');
    await pump();
    expect(states.last.status, LoginStatus.failure);
    expect(states.last.failure, AuthFailureType.unknown);
  });

  test('second submit while submitting is ignored', () async {
    repo.gate = Completer<void>();
    final first = cubit.submit(email: 'a@b.com', password: 'pw');
    await cubit.submit(email: 'a@b.com', password: 'pw');
    await pump();
    expect(repo.calls, 1);
    repo.gate!.complete();
    await first;
    await pump();
    expect(states, [submitting, const LoginState(status: LoginStatus.success)]);
  });

  test('clearError after failure returns to initial', () async {
    repo.error = const AuthFailure(AuthFailureType.network);
    await cubit.submit(email: 'a@b.com', password: 'pw');
    await pump();
    cubit.clearError();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state, const LoginState());
    expect(states.last, const LoginState());
  });

  test('clearError when not failed emits nothing', () async {
    cubit.clearError();
    await Future<void>.delayed(Duration.zero);
    expect(states, isEmpty);
  });
}
