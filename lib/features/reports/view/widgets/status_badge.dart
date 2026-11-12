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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (label, bgColor, fgColor) = switch (status) {
      'active' => (
          l10n.statusActive,
          isDark
              ? const Color(0xFF1E3A2F)
              : const Color(0xFFE8F5E9),
          isDark
              ? const Color(0xFF81C784)
              : const Color(0xFF2E7D32),
        ),
      'matching' => (
          l10n.statusMatching,
          isDark
              ? const Color(0xFF3E2F1B)
              : const Color(0xFFFFF3E0),
          isDark
              ? const Color(0xFFFFB74D)
              : const Color(0xFFE65100),
        ),
      'recovered' => (
          l10n.statusRecovered,
          isDark
              ? const Color(0xFF2A2D34)
              : const Color(0xFFECEFF1),
          isDark
              ? const Color(0xFFB0BEC5)
              : const Color(0xFF546E7A),
        ),
      _ => (
          status,
          Theme.of(context).colorScheme.surfaceContainerHighest,
          Theme.of(context).colorScheme.onSurfaceVariant,
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
