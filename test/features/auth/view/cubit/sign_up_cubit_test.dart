import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/signup_use_case.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  Object? error;
  Completer<void>? gate;
  int calls = 0;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp(SignUpParams params) async {
    calls++;
    await gate?.future;
    final e = error;
    if (e != null) throw e;
  }
}

const _params = SignUpParams(
  fullName: 'Ahmed',
  email: 'a@b.com',
  phone: '+201012345678',
  password: 'secret123',
);

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeAuthRepository repo;
  late SignUpCubit cubit;
  late List<SignUpState> states;
  late StreamSubscription<SignUpState> sub;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = SignUpCubit(SignUpUseCase(repo));
    states = [];
    sub = cubit.stream.listen(states.add);
  });

  tearDown(() async {
    await sub.cancel();
    await cubit.close();
  });

  test('success emits submitting then success', () async {
    await cubit.submit(_params);
    await pump();
    expect(states, const [
      SignUpState(status: SignUpStatus.submitting),
      SignUpState(status: SignUpStatus.success),
    ]);
  });

  test('emailAlreadyInUse failure is exposed', () async {
    repo.error = const AuthFailure(AuthFailureType.emailAlreadyInUse);
    await cubit.submit(_params);
    await pump();
    expect(
      cubit.state,
      const SignUpState(
        status: SignUpStatus.failure,
        failure: AuthFailureType.emailAlreadyInUse,
      ),
    );
  });

  test('unexpected error maps to unknown', () async {
    repo.error = StateError('boom');
    await cubit.submit(_params);
    await pump();
    expect(
      cubit.state,
      const SignUpState(
        status: SignUpStatus.failure,
        failure: AuthFailureType.unknown,
      ),
    );
  });

  test('second submit while submitting is ignored', () async {
    repo.gate = Completer<void>();
    final first = cubit.submit(_params);
    await pump();
    expect(cubit.state.isSubmitting, isTrue);
    await cubit.submit(_params);
    expect(repo.calls, 1);
    repo.gate!.complete();
    await first;
    expect(cubit.state.status, SignUpStatus.success);
  });

  test('clearError resets failure to initial only', () async {
    repo.error = const AuthFailure(AuthFailureType.network);
    await cubit.submit(_params);
    await pump();
    cubit.clearError();
    expect(cubit.state, const SignUpState());

    repo.error = null;
    await cubit.submit(_params);
    await pump();
    cubit.clearError();
    expect(cubit.state.status, SignUpStatus.success);
  });
}
