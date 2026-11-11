import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/app_button.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await pumpTestApp(
      tester,
      AppButton(label: 'Log in', onPressed: () => taps++),
    );
    await tester.tap(find.text('Log in'));
    expect(taps, 1);
  });

  testWidgets('loading shows spinner, hides label, ignores taps',
      (tester) async {
    var taps = 0;
    await pumpTestApp(
      tester,
      AppButton(label: 'Log in', isLoading: true, onPressed: () => taps++),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
  });

  testWidgets('outlined variant renders OutlinedButton', (tester) async {
    await pumpTestApp(
      tester,
      AppButton(
        label: 'Cancel',
        variant: AppButtonVariant.outlined,
        onPressed: () {},
      ),
    );
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('outlined loading shows spinner', (tester) async {
    await pumpTestApp(
      tester,
      AppButton(
        label: 'Cancel',
        variant: AppButtonVariant.outlined,
        isLoading: true,
        onPressed: () {},
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('height is 52', (tester) async {
    await pumpTestApp(tester, AppButton(label: 'Go', onPressed: () {}));
    expect(tester.getSize(find.byType(FilledButton)).height, 52);
  });
}
