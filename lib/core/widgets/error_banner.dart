import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Red inline banner for form-level errors. Announced by screen readers.
///
///   ErrorBanner(
///     title: l10n.invalidCredentials,
///     message: l10n.checkEmailAndPassword,
///   )
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.error.withValues(alpha: 0.12),
            colors.surface,
          ),
          border: Border.all(
            color: Color.alphaBlend(
              colors.error.withValues(alpha: 0.25),
              colors.surface,
            ),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(Icons.error_outline, size: 16.r, color: colors.error),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$title ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: message),
                  ],
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.45,
                  color: colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
