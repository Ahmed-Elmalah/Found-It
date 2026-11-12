import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/main/view/widgets/liquid_glass_bottom_nav_bar.dart';

/// The persistent application shell containing the [LiquidGlassBottomNavBar]
/// and hosting the main branches (Home, Explore, Messages, Profile).
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: LiquidGlassBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onReportTap: () {
          context.push(AppRoutes.createReport);
        },
      ),
    );
  }
}
