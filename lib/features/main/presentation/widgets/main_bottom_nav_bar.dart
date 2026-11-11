import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Custom bottom navigation bar of the main shell (Figma design).
///
/// Layout: four evenly spaced items - Home and Explore on the left, Messages
/// and Profile on the right - with a prominent circular Report button
/// floating in the exact center, half elevated above the bar line, its label
/// right below it. The Messages item shows an unread count badge (mock value
/// until the chat feature lands).
class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Index of the currently active branch: 0 Home, 1 Explore, 2 Report,
  /// 3 Messages, 4 Profile.
  final int selectedIndex;

  /// Called with the tapped branch index.
  final ValueChanged<int> onDestinationSelected;

  /// Height of the bar surface below the elevated Report button.
  static const double _barHeight = 64;

  /// Diameter of the center Report button.
  static const double _buttonSize = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      // The Report button rises half of its size above the bar line.
      height: _buttonSize.r / 2 + _barHeight.h + bottomPadding,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: _barHeight.h + bottomPadding,
              padding: EdgeInsets.only(bottom: bottomPadding),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: l10n.tabHome,
                    selected: selectedIndex == 0,
                    onTap: () => onDestinationSelected(0),
                  ),
                  _NavItem(
                    icon: Icons.travel_explore_outlined,
                    activeIcon: Icons.travel_explore,
                    label: l10n.tabExplore,
                    selected: selectedIndex == 1,
                    onTap: () => onDestinationSelected(1),
                  ),
                  // Reserved for the center Report button.
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: l10n.tabMessages,
                    selected: selectedIndex == 3,
                    badgeCount: 2, // Mock unread count until chat lands.
                    onTap: () => onDestinationSelected(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: l10n.tabProfile,
                    selected: selectedIndex == 4,
                    onTap: () => onDestinationSelected(4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ReportButton(onTap: () => onDestinationSelected(2)),
                SizedBox(height: 10.h),
                Text(
                  l10n.tabReport,
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One of the four corner items: icon above its label, colored by the
/// selection state, optionally with an unread badge on the icon.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Unread count rendered as a red badge on the icon's top-right corner.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = selected ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(colors, color),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colors, Color color) {
    final iconWidget = Icon(
      selected ? activeIcon : icon,
      size: 24.r,
      color: color,
    );
    if (badgeCount == null) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: -6.h,
          right: -10.w,
          child: Container(
            height: 16.r,
            constraints: BoxConstraints(minWidth: 16.r),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.error,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              badgeCount.toString(),
              style: TextStyle(
                color: colors.onError,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Prominent circular Report action floating above the bar line in the
/// exact center of the bar.
class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.primary,
      elevation: 6,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: MainBottomNavBar._buttonSize.r,
          height: MainBottomNavBar._buttonSize.r,
          child: Icon(Icons.add, size: 28.r, color: colors.onPrimary),
        ),
      ),
    );
  }
}
