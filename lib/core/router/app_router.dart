import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/ui/create_report_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.createReport,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('FOUND IT'))),
    ),
    GoRoute(
      path: AppRoutes.createReport,
      builder: (context, state) => BlocProvider(
        create: (_) => CreateReportCubit(),
        child: const CreateReportScreen(),
      ),
    ),
  ],
);