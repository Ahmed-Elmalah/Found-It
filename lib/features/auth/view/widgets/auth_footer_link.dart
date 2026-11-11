import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Centered footer line with a tappable action, e.g. "Don't have an account? Sign up".
///
/// ```dart
/// AuthFooterLink(
///   text: l10n.noAccount,
///   actionText: l10n.signUp,
///   onTap: () => context.go('/signup'),
/// )
/// ```
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Full width so WrapAlignment.center can actually center the line
    // (a Wrap alone shrinks to its content and sits at the start).
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 15.sp, color: colors.onSurfaceVariant),
          ),
          SizedBox(width: 4.w),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.primary,
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
