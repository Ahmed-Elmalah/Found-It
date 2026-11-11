import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/widgets/line_icon.dart';

/// One onboarding slide: a big icon tile, a title and a short body text.
///
///   OnboardingPage(
///     icon: LineIconType.search,
///     title: l10n.onboardingTitle1,
///     body: l10n.onboardingBody1,
///   )
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final LineIconType icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300.r,
              height: 300.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: LineIcon(
                icon,
                size: 120.r,
                color: colors.primary,
                strokeWidth: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
