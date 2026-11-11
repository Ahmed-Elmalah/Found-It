import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppButtonVariant { filled, outlined }

/// Full-width 52h button with a loading state.
///
///   AppButton(
///     label: l10n.logIn,
///     isLoading: state.isLoading,
///     onPressed: _submit,
///   )
///
///   AppButton(label: l10n.cancel, variant: AppButtonVariant.outlined, onPressed: _cancel)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filled = variant == AppButtonVariant.filled;
    final callback = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox.square(
            dimension: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: filled ? colors.onPrimary : colors.primary,
            ),
          )
        : Text(
            label,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          );

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: filled
          ? FilledButton(
              onPressed: callback,
              style: isLoading
                  ? FilledButton.styleFrom(
                      disabledBackgroundColor: colors.primary,
                      disabledForegroundColor: colors.onPrimary,
                    )
                  : null,
              child: child,
            )
          : OutlinedButton(
              onPressed: callback,
              style: isLoading
                  ? OutlinedButton.styleFrom(
                      disabledForegroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                    )
                  : null,
              child: child,
            ),
    );
  }
}
