import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/home/presentation/screens/home_screen.dart';
import 'package:found_it/features/main/presentation/screens/main_shell.dart';
import 'package:found_it/features/messages/presentation/screens/messages_screen.dart';
import 'package:found_it/features/profile/presentation/screens/profile_screen.dart';
import 'package:found_it/features/reports/presentation/screens/report_screen.dart';
import 'package:found_it/features/search/presentation/screens/explore_screen.dart';

final GoRouter appRouter = GoRouter(
  // TEMPORARY: start on the Home tab while the User Story #2 UI is being
  // signed off. Revert to AppRoutes.splash once the auth flow lands.
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('FOUND IT'))),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.report,
              builder: (context, state) => const ReportScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.messages,
              builder: (context, state) => const MessagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
