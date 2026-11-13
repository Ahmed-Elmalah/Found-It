import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';

enum HomeViewState {
  success,
  loading,
  empty,
  error,
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.cityName,
    required this.currentState,
    required this.onStateChanged,
    this.onNotificationTap,
  });

  final String cityName;
  final HomeViewState currentState;
  final ValueChanged<HomeViewState> onStateChanged;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left: App Name + City Switcher Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(AppRoutes.city);
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      splashColor: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 19.r,
                              color: primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              cityName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20.r,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Notification Bell in glass style
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onNotificationTap?.call();
                },
                borderRadius: BorderRadius.circular(22.r),
                child: Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 23.r,
                        color: theme.colorScheme.onSurface,
                      ),
                      Positioned(
                        top: 11.h,
                        right: 12.w,
                        child: Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Interactive UI State Preview Pills (For fast, effortless developer review)
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatePill(
                  label: '🟢 Success',
                  isSelected: currentState == HomeViewState.success,
                  onTap: () => onStateChanged(HomeViewState.success),
                ),
                SizedBox(width: 6.w),
                _StatePill(
                  label: '⏳ Loading',
                  isSelected: currentState == HomeViewState.loading,
                  onTap: () => onStateChanged(HomeViewState.loading),
                ),
                SizedBox(width: 6.w),
                _StatePill(
                  label: '📭 Empty',
                  isSelected: currentState == HomeViewState.empty,
                  onTap: () => onStateChanged(HomeViewState.empty),
                ),
                SizedBox(width: 6.w),
                _StatePill(
                  label: '⚠️ Error',
                  isSelected: currentState == HomeViewState.error,
                  onTap: () => onStateChanged(HomeViewState.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

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
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.28 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03)),
          border: Border.all(
            color: isSelected
                ? primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
