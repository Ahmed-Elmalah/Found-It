import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// A modern, high-performance Liquid Glass (Frosted Glassmorphic) Navigation Bar.
///
/// Features:
/// - Floating capsule dock with [BackdropFilter] frosted blur (sigma: 18).
/// - Translucent glass gradient with specular reflection border.
/// - Fluid animated capsule indicator that smoothly glides behind the active tab.
/// - Prominent center floating action button with vibrant gradient and glass glow for Report.
/// - Multi-layered soft ambient drop shadows.
/// - Tactile haptic feedback on interactions.
/// - Full RTL/LTR and dark/light mode support.
class LiquidGlassBottomNavBar extends StatelessWidget {
  const LiquidGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onReportTap,
  });

  /// The active tab index among the 4 main destinations:
  /// 0: Home, 1: Explore, 2: Notifications, 3: Profile.
  final int currentIndex;

  /// Callback when a navigation tab is selected.
  final ValueChanged<int> onTap;

  /// Callback when the center report action button is tapped.
  final VoidCallback onReportTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;

    // Map the 4 tab indices to their corresponding column index out of 5 slots:
    // Slot 0: Home, Slot 1: Explore, Slot 2: Center Button, Slot 3: Notifications, Slot 4: Profile.
    final targetCol = switch (currentIndex) {
      0 => 0,
      1 => 1,
      2 => 3,
      3 => 4,
      _ => 0,
    };

    // Calculate alignment for the sliding liquid capsule:
    // With 5 slots, column index 0 is at -1.0, 1 at -0.5, 2 at 0.0, 3 at +0.5, 4 at +1.0.
    final alignmentX = switch (targetCol) {
      0 => -1.0,
      1 => -0.5,
      3 => 0.5,
      4 => 1.0,
      _ => -1.0,
    };

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Container(
            height: 68.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.h),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C222D).withValues(alpha: 0.82),
                              const Color(0xFF12161E).withValues(alpha: 0.68),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.82),
                              Colors.white.withValues(alpha: 0.58),
                            ],
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : Colors.white.withValues(alpha: 0.75),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Liquid morphing active capsule
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment(alignmentX, 0),
                        child: FractionallySizedBox(
                          widthFactor: 0.20,
                          heightFactor: 0.82,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: primary.withValues(alpha: isDark ? 0.35 : 0.20),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 5 Interactive slots
                      Row(
                        children: [
                          // Tab 0: Home
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.home_rounded,
                              label: l10n.navHome,
                              isSelected: currentIndex == 0,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onTap(0);
                              },
                            ),
                          ),

                          // Tab 1: Explore
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.explore_rounded,
                              label: l10n.navExplore,
                              isSelected: currentIndex == 1,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onTap(1);
                              },
                            ),
                          ),

                          // Center Slot: Elevated Report Button
                          Expanded(
                            child: _CenterReportButton(
                              label: l10n.navReport,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                onReportTap();
                              },
                            ),
                          ),

                          // Tab 2: Notifications
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.notifications_rounded,
                              label: l10n.navNotifications,
                              isSelected: currentIndex == 2,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onTap(2);
                              },
                            ),
                          ),

                          // Tab 3: Profile
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.person_rounded,
                              label: l10n.navProfile,
                              isSelected: currentIndex == 3,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                onTap(3);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final color = isSelected ? primary : onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                icon,
                color: color,
                size: 24.r,
              ),
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterReportButton extends StatelessWidget {
  const _CenterReportButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B66FF),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.50 : 0.38),
                    blurRadius: 12.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26.r,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
