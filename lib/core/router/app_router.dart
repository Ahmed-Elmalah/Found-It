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
import 'package:found_it/features/profile/domain/entities/user_profile_entity.dart';
import 'package:found_it/features/profile/view/cubit/profile_cubit.dart';
import 'package:found_it/features/profile/view/ui/edit_profile_screen.dart';
import 'package:found_it/features/profile/view/ui/profile_screen.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/ui/edit_report_screen.dart';
import 'package:found_it/features/reports/view/ui/my_reports_screen.dart';

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
      builder: (context, state) {
        final report = state.extra as ReportEntity;
        return BlocProvider(
          create: (_) => EditReportCubit(
            report: report,
            updateReportUseCase: sl(),
            getCategoriesUseCase: sl(),
            getCityAreasUseCase: sl(),
          ),
          child: EditReportScreen(report: report),
        );
      },
    ),

    // Profile & Settings (Adham, story #1)
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ProfileCubit>(),
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) {
        final profile = state.extra as UserProfileEntity;
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
  const _ComingSoon(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$name — coming soon')));
  }
}
