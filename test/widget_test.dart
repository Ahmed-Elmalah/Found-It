import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/found_it.dart';

void main() {
  testWidgets('app starts without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(const FoundIt());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
