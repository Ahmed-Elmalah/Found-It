import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/features/explore/view/ui/explore_screen.dart';

import '../../../../helpers/test_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool dark = false,
  bool rtl = false,
}) async {
  final router = GoRouter(
    initialLocation: '/explore',
    routes: [
      GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen()),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title, count and mock report cards', (tester) async {
    await _pump(tester);

    expect(find.text('Explore'), findsOneWidget);
    expect(find.textContaining('8 active reports'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
    expect(find.text('Lost'), findsWidgets);
    expect(find.text('Zamalek, Cairo'), findsWidgets);
  });

  testWidgets('typing filters the list', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'wallet');
    await tester.pumpAndSettle();

    expect(find.textContaining('1 active reports'), findsOneWidget);
    expect(find.text('Black leather wallet'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsNothing);
  });

  testWidgets('the filters sheet applies a category', (tester) async {
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Show results'), findsOneWidget);

    await tester.tap(find.text('Bags'));
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(find.text('Bags'), findsOneWidget); // active filter chip
    expect(find.text('Brown leather handbag'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsNothing);
  });

  testWidgets('no matches shows the empty state', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await tester.pumpAndSettle();

    expect(find.text('No matching reports found.'), findsOneWidget);
    expect(find.text('Try adjusting your search filters.'), findsOneWidget);
  });

  testWidgets('renders in dark mode and RTL without overflowing', (
    tester,
  ) async {
    await _pump(tester, dark: true, rtl: true);

    expect(find.text('استكشاف'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
