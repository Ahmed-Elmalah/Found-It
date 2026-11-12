import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/line_icon.dart';
import 'package:found_it/features/auth/view/cubit/resend_timer_cubit.dart';
import 'package:found_it/features/auth/view/ui/verify_screen.dart';

import '../../../../helpers/test_app.dart';

GoRouter _router() => GoRouter(
  initialLocation: AppRoutes.verifyEmail,
  routes: [
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (_, _) => BlocProvider(
        create: (_) => ResendTimerCubit(),
        child: const VerifyEmailScreen(email: 'user@example.com'),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const Text('LOGIN PAGE'),
    ),
  ],
);

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('shows title, body, buttons and mail icon', (tester) async {
    await pumpTestRouterApp(tester, _router());
    await tester.pump();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.text('I’ve verified my email'), findsOneWidget);
    expect(find.text('Resend email · 00:45'), findsOneWidget);
    expect(find.byType(LineIcon), findsWidgets);
    await _dispose(tester);
  });

  testWidgets('countdown updates and tapping while counting does not reset', (
    tester,
  ) async {
    await pumpTestRouterApp(tester, _router());
    await tester.pump();

    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Resend email · 00:35'), findsOneWidget);

    await tester.tap(find.text('Resend email · 00:35'));
    await tester.pump();
    expect(find.text('Resend email · 00:35'), findsOneWidget);
    await _dispose(tester);
  });

  testWidgets('after 45s resend is enabled and restarts the countdown', (
    tester,
  ) async {
    await pumpTestRouterApp(tester, _router());
    await tester.pump();

    await tester.pump(const Duration(seconds: 45));
    expect(find.text('Resend email'), findsOneWidget);

    await tester.tap(find.text('Resend email'));
    await tester.pump();
    expect(find.text('Resend email · 00:45'), findsOneWidget);
    await _dispose(tester);
  });

  testWidgets('verified button goes to login', (tester) async {
    await pumpTestRouterApp(tester, _router());
    await tester.pump();

    await tester.tap(find.text('I’ve verified my email'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
    await _dispose(tester);
  });

  testWidgets('Arabic renders without exceptions', (tester) async {
    await pumpTestRouterApp(tester, _router(), rtl: true);
    await tester.pump();

    expect(find.text('تحقق من بريدك الإلكتروني'), findsOneWidget);
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _dispose(tester);
  });

  testWidgets('dark theme renders', (tester) async {
    await pumpTestRouterApp(tester, _router(), dark: true);
    await tester.pump();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _dispose(tester);
  });

  testWidgets('small screen 390x600 does not overflow', (tester) async {
    await pumpTestRouterApp(tester, _router());
    tester.view.physicalSize = const Size(390, 600);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Verify your email'), findsOneWidget);
    await _dispose(tester);
  });
}
