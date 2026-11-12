import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class ReportTypeBadge extends StatelessWidget {
  const ReportTypeBadge({
    super.key,
    required this.type,
  });

  final String type; // 'lost' | 'found'

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLost = type == 'lost';
    final label = isLost ? l10n.typeLost : l10n.typeFound;

    final bgColor = isLost
        ? (isDark ? const Color(0xFF3B1E22) : const Color(0xFFFFEBEE))
        : colors.primary.withValues(alpha: isDark ? 0.2 : 0.1);

    final fgColor = isLost
        ? colors.error
        : colors.primary;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
