import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
    required this.onConfirm,
    this.isLoading = false,
  });

  final VoidCallback onConfirm;
  final bool isLoading;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    bool isLoading = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => LogoutDialog(
        onConfirm: onConfirm,
        isLoading: isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: colors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Padding(
        padding: EdgeInsetsDirectional.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: colors.error,
                size: 28.r,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.logoutConfirmTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.logoutConfirmMessage,
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(color: colors.outline),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      minimumSize: Size(0, 48.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox.square(
                            dimension: 20.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onError,
                            ),
                          )
                        : Text(
                            l10n.logoutButton,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.onError,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
