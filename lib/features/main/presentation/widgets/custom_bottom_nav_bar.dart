import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_colors.dart';

/// Custom bottom navigation bar of the main shell (Figma design).
///
/// Clean white bar with a subtle top shadow. Four evenly spaced items -
/// Home and Explore on the left, Messages and Profile on the right - and a
/// prominent circular Report button floating in the exact center, elevated
/// above the bar line, with its label right below it. The Messages item
/// carries a red unread badge (mock count until the chat feature lands).
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Index of the currently active branch: 0 Home, 1 Explore, 2 Report,
  /// 3 Messages, 4 Profile.
  final int selectedIndex;

  /// Called with the tapped branch index.
  final ValueChanged<int> onDestinationSelected;

  /// Height of the white bar surface.
  static const double _barHeight = 75;

  /// Size of the circular Report button.
  static const double _buttonSize = 56;

  /// How far the Report button rises above the bar line.
  static const double _buttonElevation = 20;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _buttonElevation.h + _barHeight.h + bottomPadding,
      child: Stack(
        // Let the Report button's shadow paint over the content above.
        clipBehavior: Clip.none,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12.r,
                  ),
                ],
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
                SizedBox(height: 8.h),
                Text(
                  l10n.tabReport,
                  style: TextStyle(
                    color: _itemColor(2),
                    fontSize: 11.sp,
                    fontWeight: _itemWeight(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _itemColor(int index) => selectedIndex == index
      ? AppColors.bottomNavActive
      : AppColors.bottomNavInactive;

  FontWeight _itemWeight(int index) =>
      selectedIndex == index ? FontWeight.w600 : FontWeight.w500;
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
    final color = selected
        ? AppColors.bottomNavActive
        : AppColors.bottomNavInactive;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(color),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
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
              color: AppColors.bottomNavBadge,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Text(
              badgeCount.toString(),
              style: TextStyle(
                color: Colors.white,
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
/// exact center of the bar, with a soft blue shadow.
class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CustomBottomNavBar._buttonSize.r,
      height: CustomBottomNavBar._buttonSize.r,
      decoration: BoxDecoration(
        color: AppColors.bottomNavActive,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.bottomNavActive.withValues(alpha: 0.35),
            offset: Offset(0, 6.h),
            blurRadius: 16.r,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(Icons.add, size: 28.r, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
