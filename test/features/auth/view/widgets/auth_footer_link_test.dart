import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/auth/view/widgets/auth_footer_link.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('AuthFooterLink', () {
    testWidgets('shows both texts', (tester) async {
      await pumpTestApp(
        tester,
        AuthFooterLink(
          text: "Don't have an account?",
          actionText: 'Sign up',
          onTap: () {},
        ),
      );
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });

    testWidgets('tapping action calls onTap once', (tester) async {
      var taps = 0;
      await pumpTestApp(
        tester,
        AuthFooterLink(
          text: "Don't have an account?",
          actionText: 'Sign up',
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Sign up'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('long Arabic text in RTL does not overflow', (tester) async {
      await pumpTestApp(
        tester,
        AuthFooterLink(
          text: 'ليس لديك حساب؟ هذا نص طويل جدا لاختبار الالتفاف في الشاشات الصغيرة',
          actionText: 'إنشاء حساب',
          onTap: () {},
        ),
        rtl: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('إنشاء حساب'), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await pumpTestApp(
        tester,
        AuthFooterLink(
          text: 'Have an account?',
          actionText: 'Log in',
          onTap: () {},
        ),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('line is centered horizontally (design)', (tester) async {
      await pumpTestApp(
        tester,
        // short text: the test font makes every letter 15 px wide, so a long
        // text would wrap to 2 lines and the check below would be meaningless
        AuthFooterLink(
          text: 'No account?',
          actionText: 'Sign up',
          onTap: () {},
        ),
      );
      // the line spans from the start of the text to the end of the action
      final left = tester.getTopLeft(find.text('No account?')).dx;
      final right = tester.getTopRight(find.byType(TextButton)).dx;
      final lineCenter = (left + right) / 2;
      // pumpTestApp: screen 390 wide with 16 padding -> content center = 195
      expect(lineCenter, closeTo(195, 2));
    });
  });
}
