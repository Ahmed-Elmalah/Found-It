import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/widgets/error_banner.dart';

import '../../helpers/test_app.dart';

void main() {
  const banner = ErrorBanner(
    title: 'Invalid Credentials:',
    message: 'Please check your email and password.',
  );

  testWidgets('shows title, message and icon', (tester) async {
    await pumpTestApp(tester, banner);
    expect(
      find.textContaining('Invalid Credentials:', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Please check your email', findRichText: true),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('renders in dark theme without errors', (tester) async {
    await pumpTestApp(tester, banner, dark: true);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
