import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/widgets_preview_screen.dart';
import 'package:found_it/features/explore/view/ui/explore_screen.dart';

final GoRouter appRouter = GoRouter(
  // TEMPORARY: start on the Task #1 widget preview for design sign-off.
  // Revert to AppRoutes.splash before merging User Story #2.
  initialLocation: AppRoutes.widgetsPreview,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('FOUND IT'))),
    ),
    GoRoute(
      path: AppRoutes.widgetsPreview,
      builder: (context, state) => const WidgetsPreviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.explore,
      builder: (context, state) => const ExploreScreen(),
    ),
  ],
);
