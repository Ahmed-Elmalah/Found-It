import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Informational banner shown on the compare screen to assure users that
/// private details are hidden to prevent fraudulent claims.
class PrivateDetailsBanner extends StatelessWidget {
  const PrivateDetailsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: colors.primary,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              l10n.hiddenDetailsNotice,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
