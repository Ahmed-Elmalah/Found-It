import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Interactive banner displayed on Home when the user has new potential matches (P15/P48).
class HomePotentialMatchesBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const HomePotentialMatchesBanner({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: isDark
                  ? [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ]
                  : [
                      const Color(0xFFEFF6FF),
                      const Color(0xFFDBEAFE),
                    ],
            ),
            border: Border.all(
              color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Badge Icon
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                ),
                child: Icon(
                  Icons.compare_arrows_rounded,
                  color: primary,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),

              // Title Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.potentialMatchesForYou(count),
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Trailing Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
