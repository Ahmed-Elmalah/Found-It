import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/onboarding/view/widgets/page_indicator.dart';

import '../../../../helpers/test_app.dart';

Finder get _dots => find.descendant(
  of: find.byType(PageIndicator),
  matching: find.byType(AnimatedContainer),
);

double _width(WidgetTester tester, int i) => tester.getSize(_dots.at(i)).width;

Color? _color(WidgetTester tester, int i) =>
    (tester.widget<AnimatedContainer>(_dots.at(i)).decoration! as BoxDecoration)
        .color;

void main() {
  testWidgets('current=0 makes the first dot wide', (tester) async {
    await pumpTestApp(tester, const PageIndicator(count: 3, current: 0));
    await tester.pumpAndSettle();
    expect(_dots, findsNWidgets(3));
    expect(_width(tester, 0), 24);
    expect(_width(tester, 1), 8);
    expect(_width(tester, 2), 8);
  });

  testWidgets('current=2 makes the last dot wide', (tester) async {
    await pumpTestApp(tester, const PageIndicator(count: 3, current: 2));
    await tester.pumpAndSettle();
    expect(_width(tester, 0), 8);
    expect(_width(tester, 1), 8);
    expect(_width(tester, 2), 24);
  });

  testWidgets('active dot is primary, inactive is outline', (tester) async {
    await pumpTestApp(tester, const PageIndicator(count: 3, current: 1));
    await tester.pumpAndSettle();
    final colors = Theme.of(tester.element(_dots.first)).colorScheme;
    expect(_color(tester, 1), colors.primary);
    expect(_color(tester, 0), colors.outline);
    expect(_color(tester, 2), colors.outline);
  });

  testWidgets('in rtl the first dot is the right-most', (tester) async {
    await pumpTestApp(
      tester,
      const PageIndicator(count: 3, current: 0),
      rtl: true,
    );
    await tester.pumpAndSettle();
    expect(_width(tester, 0), 24);
    expect(
      tester.getCenter(_dots.at(0)).dx,
      greaterThan(tester.getCenter(_dots.at(2)).dx),
    );
  });
}
