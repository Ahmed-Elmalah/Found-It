import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/onboarding/view/cubit/splash_cubit.dart';
import 'package:found_it/features/onboarding/view/widgets/splash_view.dart';

/// Splash: shows [SplashView] and navigates when [SplashCubit] decides.
/// The cubit is provided from outside (router) and already started.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is! SplashNavigate) return;
        switch (state.destination) {
          case SplashDestination.onboarding:
            context.go(AppRoutes.onboarding);
          case SplashDestination.login:
            context.go(AppRoutes.login);
          case SplashDestination.home:
            context.go(AppRoutes.home);
        }
      },
      child: const SplashView(),
    );
  }
}
