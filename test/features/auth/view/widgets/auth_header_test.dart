import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/auth/view/widgets/auth_header.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('AuthHeader', () {
    testWidgets('shows title and subtitle', (tester) async {
      await pumpTestApp(
        tester,
        const AuthHeader(title: 'Welcome back', subtitle: 'Log in to continue.'),
      );
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Log in to continue.'), findsOneWidget);
    });

    testWidgets('without subtitle shows only the title', (tester) async {
      await pumpTestApp(tester, const AuthHeader(title: 'Welcome back'));
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('title is 28 / w700', (tester) async {
      await pumpTestApp(tester, const AuthHeader(title: 'Welcome back'));
      final text = tester.widget<Text>(find.text('Welcome back'));
      expect(text.style?.fontSize, 28);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('long subtitle wraps without exceptions', (tester) async {
      await pumpTestApp(
        tester,
        const AuthHeader(
          title: 'Forgot password',
          subtitle:
              "Enter your email and we'll send you a link to reset it. More text to force wrapping.",
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL: title sits at the right edge', (tester) async {
      await pumpTestApp(tester, const AuthHeader(title: 'Hi'), rtl: true);
      final right = tester.getTopRight(find.text('Hi')).dx;
      // 390 wide screen minus 16 padding.
      expect(right, closeTo(390 - 16, 0.5));
    });

    testWidgets('LTR: title sits at the left edge', (tester) async {
      await pumpTestApp(tester, const AuthHeader(title: 'Hi'));
      expect(tester.getTopLeft(find.text('Hi')).dx, closeTo(16, 0.5));
    });
  });
}
