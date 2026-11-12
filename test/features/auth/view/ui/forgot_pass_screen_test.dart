import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/features/auth/view/ui/forgot_pass_screen.dart';

import '../../../../helpers/test_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool dark = false,
  bool rtl = false,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, _) => Scaffold(
          body: Column(
            children: [
              const Text('LOGIN PAGE'),
              TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('open'),
              ),
            ],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _submitWith(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextField), email);
  await tester.tap(find.widgetWithText(AppButton, 'Send reset link'));
  await tester.pump();
}

void main() {
  testWidgets('shows texts', (tester) async {
    await _pump(tester);
    for (final t in [
      'Forgot password?',
      'Enter your email and we’ll send you a link to reset it.',
      'Email',
      'Send reset link',
      'Remembered it?',
      'Back to login',
    ]) {
      expect(find.text(t), findsWidgets, reason: t);
    }
  });

  testWidgets('empty submit shows Required, no snackbar', (tester) async {
    await _pump(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Send reset link'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('invalid email shows error, no snackbar', (tester) async {
    await _pump(tester);
    await _submitWith(tester, 'abc');
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('valid email shows coming-soon snackbar', (tester) async {
    await _pump(tester);
    await _submitWith(tester, 'a@b.com');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Password reset will be available soon.'), findsOneWidget);
    expect(find.text('Required'), findsNothing);
  });

  testWidgets('back arrow returns to login', (tester) async {
    await _pump(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });

  testWidgets('Back to login returns to login', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Back to login'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });

  testWidgets('Arabic renders without exceptions', (tester) async {
    await _pump(tester, rtl: true);
    expect(find.text('نسيت كلمة المرور؟'), findsWidgets);
    expect(find.text('إرسال رابط إعادة التعيين'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders without exceptions', (tester) async {
    await _pump(tester, dark: true);
    expect(find.text('Forgot password?'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen does not overflow', (tester) async {
    await _pump(tester);
    tester.view.physicalSize = const Size(390, 600);
    await tester.pumpAndSettle();
    await _submitWith(tester, 'abc');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Enter a valid email'), findsOneWidget);
  });
}
