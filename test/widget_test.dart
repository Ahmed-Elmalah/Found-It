import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/found_it.dart';

void main() {
  testWidgets('app starts without exceptions', (WidgetTester tester) async {
    // Run at the design frame's device profile (390x844 @ 3x) so the
    // ScreenUtil-based layout is exercised as it is on a real phone.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FoundIt());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
