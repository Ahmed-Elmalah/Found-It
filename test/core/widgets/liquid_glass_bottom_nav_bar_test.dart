import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/liquid_glass_bottom_nav_bar.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('renders all 4 tabs and center report button in English', (tester) async {
    int selectedIndex = 0;
    bool reportTapped = false;

    await pumpTestApp(
      tester,
      LiquidGlassBottomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) => selectedIndex = index,
        onReportTap: () => reportTapped = true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap Explore (index 1)
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);

    // Tap Report
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(reportTapped, isTrue);

    // Tap Profile (index 3)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(selectedIndex, 3);
  });

  testWidgets('renders Arabic texts and RTL layout', (tester) async {
    await pumpTestApp(
      tester,
      LiquidGlassBottomNavBar(
        currentIndex: 0,
        onTap: (_) {},
        onReportTap: () {},
      ),
      rtl: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('استكشاف'), findsOneWidget);
    expect(find.text('إبلاغ'), findsOneWidget);
    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
  });

  testWidgets('renders in Dark mode without errors', (tester) async {
    await pumpTestApp(
      tester,
      LiquidGlassBottomNavBar(
        currentIndex: 2,
        onTap: (_) {},
        onReportTap: () {},
      ),
      dark: true,
    );
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassBottomNavBar), findsOneWidget);
  });
}
