import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (label, bgColor, fgColor) = switch (status) {
      'active' => (
          l10n.statusActive,
          colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
          colors.primary,
        ),
      'matching' => (
          l10n.statusMatching,
          colors.secondary.withValues(alpha: isDark ? 0.22 : 0.12),
          colors.secondary,
        ),
      'recovered' => (
          l10n.statusRecovered,
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        ),
      _ => (
          status,
          colors.surfaceContainerHighest,
          colors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
