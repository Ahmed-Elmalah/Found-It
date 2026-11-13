import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import '../../domain/entities/home_report_item.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.allCount,
    this.lostCount,
    this.foundCount,
  });

  final HomeFilterType selectedFilter;
  final ValueChanged<HomeFilterType> onFilterSelected;
  final int? allCount;
  final int? lostCount;
  final int? foundCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.homeFilterAll,
            count: allCount,
            isSelected: selectedFilter == HomeFilterType.all,
            icon: Icons.dashboard_outlined,
            onTap: () => onFilterSelected(HomeFilterType.all),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: l10n.homeFilterLost,
            count: lostCount,
            isSelected: selectedFilter == HomeFilterType.lost,
            icon: Icons.search_rounded,
            badgeColor: const Color(0xFFEF4444),
            onTap: () => onFilterSelected(HomeFilterType.lost),
          ),
          SizedBox(width: 8.w),
          _FilterChip(
            label: l10n.homeFilterFound,
            count: foundCount,
            isSelected: selectedFilter == HomeFilterType.found,
            icon: Icons.check_circle_outline_rounded,
            badgeColor: const Color(0xFF10B981),
            onTap: () => onFilterSelected(HomeFilterType.found),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
    this.count,
    this.badgeColor,
  });

  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;
  final int? count;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(24.r),
      splashColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isSelected
              ? primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.07)),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: 10.r,
                    offset: Offset(0, 3.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected
                  ? Colors.white
                  : (badgeColor ?? theme.colorScheme.onSurfaceVariant),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.06)),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
