import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/onboarding/domain/is_first_launch_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';

class _FakeOnboardingRepo implements OnboardingRepository {
  _FakeOnboardingRepo({this.first = false, this.throws = false});
  final bool first;
  final bool throws;

  @override
  bool isFirstLaunch() {
    if (throws) throw Exception('boom');
    return first;
  }

  @override
  Future<void> completeOnboarding() async {}
}

class _FakeAuthRepo implements AuthRepository {
  // Sign up is not used by this test.
  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();

  _FakeAuthRepo(this.session);
  final bool session;

  @override
  bool hasActiveSession() => session;

  // Not used by the splash; required by the AuthRepository interface.
  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();
}

SplashCubit _build({
  bool first = false,
  bool session = false,
  bool throws = false,
  Duration minDisplay = Duration.zero,
}) => SplashCubit(
  IsFirstLaunchUseCase(_FakeOnboardingRepo(first: first, throws: throws)),
  HasActiveSessionUseCase(_FakeAuthRepo(session)),
  minDisplay: minDisplay,
);

Future<List<SplashState>> _run(SplashCubit cubit) async {
  final states = <SplashState>[];
  final sub = cubit.stream.listen(states.add);
  await cubit.start();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  await cubit.close();
  return states;
}

void main() {
  test('first launch goes to onboarding even with a session', () async {
    final states = await _run(_build(first: true, session: true));
    expect(states, [const SplashNavigate(SplashDestination.onboarding)]);
  });

  test('not first launch with session goes to home', () async {
    final states = await _run(_build(session: true));
    expect(states, [const SplashNavigate(SplashDestination.home)]);
  });

  test('not first launch without session goes to login', () async {
    final states = await _run(_build());
    expect(states, [const SplashNavigate(SplashDestination.login)]);
  });

  test('use case throwing falls back to login', () async {
    final states = await _run(_build(throws: true, session: true));
    expect(states, [const SplashNavigate(SplashDestination.login)]);
  });

  test('start twice navigates once', () async {
    final cubit = _build(session: true);
    final states = <SplashState>[];
    final sub = cubit.stream.listen(states.add);
    await Future.wait([cubit.start(), cubit.start()]);
    await cubit.start();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await cubit.close();
    expect(states.length, 1);
  });

  test('does not emit before minDisplay elapsed', () async {
    final cubit = _build(
      session: true,
      minDisplay: const Duration(milliseconds: 50),
    );
    final states = <SplashState>[];
    final sub = cubit.stream.listen(states.add);
    final future = cubit.start();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(states, isEmpty);
    await future;
    await Future<void>.delayed(Duration.zero);
    expect(states, [const SplashNavigate(SplashDestination.home)]);
    await sub.cancel();
    await cubit.close();
  });
}
