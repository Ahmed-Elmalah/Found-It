import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_colors.dart';

/// Pill badge showing similarity percentage, e.g. "92% Match".
class MatchScoreBadge extends StatelessWidget {
  final int similarity;

  const MatchScoreBadge({
    super.key,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badgeColor = similarity >= 75
        ? (isDark ? AppColors.successDark : AppColors.successLight)
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 13.r,
            color: badgeColor,
          ),
          SizedBox(width: 4.w),
          Text(
            l10n.similarityScore(similarity),
            style: TextStyle(
              color: badgeColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
