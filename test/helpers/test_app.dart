import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';

/// Pumps [child] the way the real app shows it: app theme, translations
/// (AppLocalizations) and ScreenUtil with the Figma frame (390 x 844).
///
/// The test screen is also 390 x 844 at 1x, so `16.w == 16` in tests and you
/// can compare sizes with the Figma numbers directly.
///
/// [rtl] = Arabic (locale 'ar', right-to-left). [padded] = false gives the
/// child the full screen (for whole screens like Splash / Onboarding).
///
///   await pumpTestApp(tester, const AppButton(label: 'Log in', onPressed: null));
///   await pumpTestApp(tester, myWidget, dark: true, rtl: true);
///   await pumpTestApp(tester, const SplashView(), padded: false);
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
  bool rtl = false,
  bool padded = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        locale: Locale(rtl ? 'ar' : 'en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: padded
              ? Scaffold(
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                )
              : child,
        ),
      ),
    ),
  );
}

/// Like [pumpTestApp] but for whole screens that navigate with go_router
/// (`context.go(...)`). Build a small GoRouter in the test with the screen
/// under test plus simple stand-in pages for the destinations:
///
///   final router = GoRouter(initialLocation: AppRoutes.onboarding, routes: [
///     GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
///     GoRoute(path: AppRoutes.login, builder: (_, __) => const Text('LOGIN PAGE')),
///   ]);
///   await pumpTestRouterApp(tester, router);
Future<void> pumpTestRouterApp(
  WidgetTester tester,
  GoRouter router, {
  bool dark = false,
  bool rtl = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: dark ? AppTheme.dark : AppTheme.light,
        locale: Locale(rtl ? 'ar' : 'en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
}
