import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/app_logo.dart';
import 'package:found_it/features/onboarding/view/widgets/splash_view.dart';

import '../../../../helpers/test_app.dart';

Color? _background(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;

ThemeData _theme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(SplashView)));

void main() {
  testWidgets('shows name and English tagline', (tester) async {
    await pumpTestApp(tester, const SplashView(), padded: false);
    expect(find.text('FOUND IT'), findsOneWidget);
    expect(find.text('Lost something? Let’s bring it back.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Arabic tagline in rtl', (tester) async {
    await pumpTestApp(tester, const SplashView(), rtl: true, padded: false);
    expect(find.text('فقدت شيئًا؟ دعنا نُعيده إليك.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('light background is primary', (tester) async {
    await pumpTestApp(tester, const SplashView(), padded: false);
    expect(_background(tester), _theme(tester).colorScheme.primary);
  });

  testWidgets('dark background is scaffold background', (tester) async {
    await pumpTestApp(tester, const SplashView(), dark: true, padded: false);
    expect(_background(tester), _theme(tester).scaffoldBackgroundColor);
  });

  testWidgets('logo is horizontally centered', (tester) async {
    await pumpTestApp(tester, const SplashView(), padded: false);
    expect(tester.getCenter(find.byType(AppLogo)).dx, closeTo(195, 1));
  });
}
