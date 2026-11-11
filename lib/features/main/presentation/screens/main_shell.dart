import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/features/main/presentation/widgets/main_bottom_nav_bar.dart';

/// Persistent navigation shell of the app.
///
/// Hosts the five root tabs - Home, Explore, Report, Messages and Profile -
/// and keeps the custom bottom navigation bar visible while switching
/// between them (each tab is a branch of the [StatefulShellRoute]).
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: MainBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Tapping the current tab again returns to its root location.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
