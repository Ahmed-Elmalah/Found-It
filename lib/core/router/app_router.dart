import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) =>
      const Scaffold(body: Center(child: Text('FOUND IT'))),
    ),
  ],
);