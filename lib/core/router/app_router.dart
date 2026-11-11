import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';
import 'package:found_it/features/auth/view/ui/login_screen.dart';
import 'package:found_it/features/auth/view/ui/signup_screen.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/onboarding/view/ui/onboarding_screen.dart';
import 'package:found_it/features/onboarding/view/ui/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    // Splash decides where to go: onboarding (first launch), home or login.
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SplashCubit>()..start(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<OnboardingCubit>(),
        child: const OnboardingScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<LoginCubit>(),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SignUpCubit>(),
        child: const SignUpScreen(),
      ),
    ),
    // TEMP: replaced by the real Choose City screen (Youssef, story #4).
    GoRoute(
      path: AppRoutes.city,
      builder: (context, state) => const _ComingSoon('City'),
    ),
    // TEMP: replaced by the real Forgot password screen (Ahmed, stage 7).
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const _ComingSoon('Forgot password'),
    ),
    // TEMP: replaced by the real Home screen (Youssef, story #4).
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _ComingSoon('Home'),
    ),
  ],
);

/// TEMP placeholder for screens that aren't built yet (dev only, no l10n).
class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$name — coming soon')));
  }
}
