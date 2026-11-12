import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/router/auth_redirect.dart';
import 'package:found_it/core/router/stream_listenable.dart';
import 'package:found_it/features/auth/view/cubit/auth_cubit.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';
import 'package:found_it/features/auth/view/cubit/resend_timer_cubit.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';
import 'package:found_it/features/auth/view/ui/forgot_pass_screen.dart';
import 'package:found_it/features/auth/view/ui/login_screen.dart';
import 'package:found_it/features/auth/view/ui/signup_screen.dart';
import 'package:found_it/features/auth/view/ui/verify_screen.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/onboarding/view/ui/onboarding_screen.dart';
import 'package:found_it/features/onboarding/view/ui/splash_screen.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/ui/create_report_screen.dart';
import 'package:found_it/features/reports/view/ui/report_created_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  // Re-check the rules below every time the login state changes
  // (login, sign up, logout, session expired, profile loaded).
  refreshListenable: StreamListenable(sl<AuthCubit>().stream),
  // Page protection — the rules live in auth_redirect.dart (with tests):
  // not logged in -> login; logged in without a city -> city;
  // logged in on login/sign up/forgot -> home.
  redirect: (context, state) {
    final auth = sl<AuthCubit>().state;
    return authRedirect(
      isLoggedIn: auth.isLoggedIn,
      hasCity: auth.hasCity,
      location: state.matchedLocation,
    );
  },
  routes: [
    // Splash decides where to go: onboarding (first launch), home or login
    // (home -> the redirect above sends users without a city to city).
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
    // UI only for now (no SMTP yet): shows a "coming soon" message.
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Not in the flow yet (email confirmation is off). Pass the email:
    //   context.go(AppRoutes.verifyEmail, extra: email)
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ResendTimerCubit>(),
        child: VerifyEmailScreen(email: (state.extra as String?) ?? ''),
      ),
    ),
    // TEMP: replaced by the real Home screen (Youssef, story #4).
    // Has a TEMP "Log out" button so the session can be tested.
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _ComingSoon('Home', withLogout: true),
    ),

    // Reports routes
    GoRoute(
      path: AppRoutes.createReport,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CreateReportCubit>(),
        child: const CreateReportScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.reportCreated,
      redirect: (context, state) {
        final extra = state.extra;
        if (extra is! String || extra.isEmpty) {
          return AppRoutes.home;
        }
        return null;
      },
      builder: (context, state) {
        final refCode = state.extra! as String;
        return ReportCreatedScreen(referenceId: refCode);
      },
    ),
  ],
);

/// TEMP placeholder for screens that aren't built yet (dev only, no l10n).
class _ComingSoon extends StatelessWidget {
  const _ComingSoon(this.name, {this.withLogout = false});

  final String name;
  final bool withLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$name — coming soon'),
            if (withLogout) ...[
              const SizedBox(height: 24),
              // The real logout button lives in Profile (Adham):
              //   context.read<AuthCubit>().logout()
              OutlinedButton(
                onPressed: () => context.read<AuthCubit>().logout(),
                child: const Text('Log out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
