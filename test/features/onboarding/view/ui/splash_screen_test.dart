import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/onboarding/domain/is_first_launch_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/onboarding/view/ui/splash_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeOnboardingRepo implements OnboardingRepository {
  _FakeOnboardingRepo(this.first);
  final bool first;

  @override
  bool isFirstLaunch() => first;

  @override
  Future<void> completeOnboarding() async {}
}

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this.session);
  final bool session;

  @override
  bool hasActiveSession() => session;
}

GoRouter _router({
  required bool first,
  required bool session,
  Duration minDisplay = Duration.zero,
}) {
  final cubit = SplashCubit(
    IsFirstLaunchUseCase(_FakeOnboardingRepo(first)),
    HasActiveSessionUseCase(_FakeAuthRepo(session)),
    minDisplay: minDisplay,
  );
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => BlocProvider(
          create: (_) => cubit..start(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const Text('ONBOARDING PAGE'),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const Text('LOGIN PAGE'),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('HOME PAGE')),
    ],
  );
}

void main() {
  testWidgets('first launch goes to onboarding', (tester) async {
    await pumpTestRouterApp(tester, _router(first: true, session: true));
    await tester.pumpAndSettle();
    expect(find.text('ONBOARDING PAGE'), findsOneWidget);
  });

  testWidgets('not first launch with session goes to home', (tester) async {
    await pumpTestRouterApp(tester, _router(first: false, session: true));
    await tester.pumpAndSettle();
    expect(find.text('HOME PAGE'), findsOneWidget);
  });

  testWidgets('not first launch without session goes to login', (tester) async {
    await pumpTestRouterApp(tester, _router(first: false, session: false));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });

  testWidgets('shows the splash before navigating', (tester) async {
    await pumpTestRouterApp(
      tester,
      _router(
        first: false,
        session: false,
        minDisplay: const Duration(milliseconds: 100),
      ),
    );
    await tester.pump();
    expect(find.text('FOUND IT'), findsOneWidget);
    expect(find.text('LOGIN PAGE'), findsNothing);

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
    expect(find.text('FOUND IT'), findsNothing);
  });
}
