import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Shell widget that wraps the main tabs (Home, My Reports, Profile)
/// with a [NavigationBar].
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64.h,
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.home, size: 24.sp, color: cs.primary),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined, size: 24.sp),
            selectedIcon: Icon(Icons.article, size: 24.sp, color: cs.primary),
            label: l10n.navMyReports,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, size: 24.sp),
            selectedIcon: Icon(Icons.person, size: 24.sp, color: cs.primary),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
