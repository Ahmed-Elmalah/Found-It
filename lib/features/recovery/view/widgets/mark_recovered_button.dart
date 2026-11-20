import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_colors.dart';
import 'package:found_it/features/recovery/view/widgets/recovery_confirmation_dialog.dart';

enum MarkRecoveredButtonVariant {
  fullWidth,
  compact,
}

/// Reusable button to mark an item as recovered (used in Chat header P32/P66,
/// Handover screen, and Report Details).
class MarkRecoveredButton extends StatelessWidget {
  final VoidCallback onConfirmed;
  final bool isLoading;
  final MarkRecoveredButtonVariant variant;

  const MarkRecoveredButton({
    super.key,
    required this.onConfirmed,
    this.isLoading = false,
    this.variant = MarkRecoveredButtonVariant.fullWidth,
  });

  void _handleTap(BuildContext context) {
    if (isLoading) return;
    RecoveryConfirmationDialog.show(
      context,
      onConfirm: onConfirmed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor =
        isDark ? AppColors.successDark : AppColors.successLight;
    final onColor = isDark ? const Color(0xFF0F1218) : Colors.white;

    if (variant == MarkRecoveredButtonVariant.compact) {
      return TextButton.icon(
        onPressed: isLoading ? null : () => _handleTap(context),
        icon: isLoading
            ? SizedBox.square(
                dimension: 14.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: successColor,
                ),
              )
            : Icon(
                Icons.check_circle_outline_rounded,
                size: 16.r,
                color: successColor,
              ),
        label: Text(
          l10n.confirmRecovery,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: successColor,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          backgroundColor: successColor.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: isLoading ? null : () => _handleTap(context),
        style: FilledButton.styleFrom(
          backgroundColor: successColor,
          foregroundColor: onColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: isLoading
            ? SizedBox.square(
                dimension: 18.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: onColor,
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          l10n.markAsRecovered,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
