import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Big title with an optional grey subtitle, shown at the top of auth screens.
///
/// ```dart
/// AuthHeader(
///   title: l10n.welcomeBack,
///   subtitle: l10n.loginToContinue,
/// )
/// ```
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subtitle = this.subtitle;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
