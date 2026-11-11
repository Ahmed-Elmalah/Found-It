import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/widgets/app_logo.dart';

/// Splash screen visuals only (logo, name, tagline). No logic or navigation.
///
///   const SplashView()
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : colors.primary,
      body: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 96),
              SizedBox(height: 20.h),
              Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark ? colors.onSurface : colors.onPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark
                      ? colors.onSurfaceVariant
                      : colors.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
