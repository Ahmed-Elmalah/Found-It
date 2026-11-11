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
        AuthFooterLink(text: 'Have an account?', actionText: 'Log in', onTap: () {}),
        dark: true,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Log in'), findsOneWidget);
    });
  });
}
