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
import 'package:found_it/features/city/view/cubit/city_cubit.dart';
import 'package:found_it/features/city/view/ui/choose_city_screen.dart';
import 'package:found_it/features/explore/view/ui/explore_screen.dart';
import 'package:found_it/features/home/view/cubit/home_cubit.dart';
import 'package:found_it/features/home/view/ui/home_screen.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/onboarding/view/ui/onboarding_screen.dart';
import 'package:found_it/features/onboarding/view/ui/splash_screen.dart';
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/ui/edit_profile_screen.dart';
import 'package:found_it/features/profile/view/ui/profile_screen.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/ui/create_report_screen.dart';
import 'package:found_it/features/reports/view/ui/edit_report_screen.dart';
import 'package:found_it/features/reports/view/ui/my_reports_screen.dart';
import 'package:found_it/features/reports/view/ui/report_created_screen.dart';
import 'package:found_it/features/root/view/ui/main_shell.dart';

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
    GoRoute(
      path: AppRoutes.city,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CityCubit>()..loadCities(),
        child: const ChooseCityScreen(),
      ),
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

    // Persistent Application Shell with Liquid Glass Navigation Bar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(
        navigationShell: navigationShell,
      ),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<HomeCubit>()..init(),
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        // Tab 1: Explore (Phase 1, mock data)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        // Tab 2: Messages
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.messages,
              builder: (context, state) => const _ComingSoon('Messages'),
            ),
          ],
        ),
        // Tab 3: Profile & Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => BlocProvider(
                create: (_) => sl<ProfileCubit>(),
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // Reports routes (Ziad, story #3)
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

    // My Reports (Adham, story #1)
    GoRoute(
      path: AppRoutes.myReports,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<MyReportsCubit>(),
        child: const MyReportsScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editReport,
      redirect: (context, state) {
        if (state.extra is! ReportEntity) {
          return AppRoutes.myReports;
        }
        return null;
      },
      builder: (context, state) {
        final report = state.extra! as ReportEntity;
        return BlocProvider(
          create: (_) => EditReportCubit(
            report,
            sl(),
            sl(),
            sl(),
          ),
          child: EditReportScreen(report: report),
        );
      },
    ),

    // Edit Profile (Adham, story #1)
    GoRoute(
      path: AppRoutes.editProfile,
      redirect: (context, state) {
        if (state.extra is! UserProfileEntity) {
          return AppRoutes.profile;
        }
        return null;
      },
      builder: (context, state) {
        final profile = state.extra! as UserProfileEntity;
        return BlocProvider(
          create: (_) => sl<ProfileCubit>(),
          child: EditProfileScreen(profile: profile),
        );
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
