import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/line_icon.dart';
import 'package:found_it/features/onboarding/view/widgets/onboarding_page.dart';

import '../../../../helpers/test_app.dart';

Finder get _tile => find.byWidgetPredicate(
  (w) =>
      w is Container &&
      w.decoration is BoxDecoration &&
      (w.decoration! as BoxDecoration).borderRadius ==
          BorderRadius.circular(32),
);

Widget _page({String body = 'Body text'}) =>
    OnboardingPage(icon: LineIconType.search, title: 'Title text', body: body);

void main() {
  testWidgets('shows title and body', (tester) async {
    await pumpTestApp(tester, _page(), padded: false);
    expect(find.text('Title text'), findsOneWidget);
    expect(find.text('Body text'), findsOneWidget);
  });

  testWidgets('tile is 300x300 and centered horizontally', (tester) async {
    await pumpTestApp(tester, _page(), padded: false);
    expect(tester.getSize(_tile), const Size(300, 300));
    expect(tester.getCenter(_tile).dx, closeTo(195, 1));
  });

  for (final dark in [false, true]) {
    testWidgets('tile color is surfaceContainerHighest (dark=$dark)', (
      tester,
    ) async {
      await pumpTestApp(tester, _page(), padded: false, dark: dark);
      final colors = Theme.of(tester.element(_tile)).colorScheme;
      final box = tester.widget<Container>(_tile).decoration! as BoxDecoration;
      expect(box.color, colors.surfaceContainerHighest);
    });
  }

  testWidgets('shows a LineIcon of the given type', (tester) async {
    await pumpTestApp(tester, _page(), padded: false);
    final icon = tester.widget<LineIcon>(find.byType(LineIcon));
    expect(icon.type, LineIconType.search);
    expect(icon.size, 120);
  });

  testWidgets('title is 26 / w700', (tester) async {
    await pumpTestApp(tester, _page(), padded: false);
    final style = tester.widget<Text>(find.text('Title text')).style!;
    expect(style.fontSize, 26);
    expect(style.fontWeight, FontWeight.w700);
  });

  for (final rtl in [false, true]) {
    testWidgets('no overflow with very long body (rtl=$rtl)', (tester) async {
      await pumpTestApp(
        tester,
        _page(body: List.filled(80, 'long body sentence').join(' ')),
        padded: false,
        rtl: rtl,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
