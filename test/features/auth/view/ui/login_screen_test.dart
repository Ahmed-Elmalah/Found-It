import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/login_use_case.dart';
import 'package:found_it/features/auth/view/cubit/login_cubit.dart';
import 'package:found_it/features/auth/view/ui/login_screen.dart';

import '../../../../helpers/test_app.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<bool> authStateChanges() => const Stream.empty();

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  // Sign up is not used by this test.
  @override
  Future<void> signUp(SignUpParams params) => throw UnimplementedError();

  int loginCalls = 0;
  AuthFailure? failure;
  Completer<void>? pending;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls++;
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
  }
}

Future<FakeAuthRepository> _pump(
  WidgetTester tester, {
  AuthFailure? failure,
  Completer<void>? pending,
  bool dark = false,
  bool rtl = false,
}) async {
  final repo = FakeAuthRepository()
    ..failure = failure
    ..pending = pending;
  final cubit = LoginCubit(LoginUseCase(repo));
  addTearDown(cubit.close);
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) =>
            BlocProvider.value(value: cubit, child: const LoginScreen()),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('HOME PAGE')),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) => const Text('SIGN UP PAGE'),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const Text('FORGOT PAGE'),
      ),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = 'a@b.com',
  String password = 'secret123',
}) async {
  await tester.enterText(find.byType(TextField).at(0), email);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.tap(find.widgetWithText(AppButton, 'Log in'));
  await tester.pump();
}

List<Color?> _enabledBorderColors(WidgetTester tester) {
  return tester
      .widgetList<TextField>(find.byType(TextField))
      .map(
        (f) => (f.decoration!.enabledBorder as OutlineInputBorder?)
            ?.borderSide
            .color,
      )
      .toList();
}

void main() {
  testWidgets('shows texts and has no back button', (tester) async {
    await _pump(tester);
    for (final t in [
      'Welcome back',
      'Log in to continue.',
      'Email',
      'Password',
      'Forgot password?',
      'Log in',
      'Sign up',
    ]) {
      expect(find.text(t), findsWidgets, reason: t);
    }
    expect(find.byType(BackButton), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('empty fields show Required twice and do not call repo', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await tester.tap(find.widgetWithText(AppButton, 'Log in'));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(2));
    expect(repo.loginCalls, 0);
  });

  testWidgets('invalid email shows error', (tester) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester, email: 'not-an-email');
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repo.loginCalls, 0);
  });

  testWidgets('invalid credentials: banner, red fields, cleared on typing', (
    tester,
  ) async {
    final repo = await _pump(
      tester,
      failure: const AuthFailure(AuthFailureType.invalidCredentials),
    );
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(repo.loginCalls, 1);
    expect(
      find.textContaining('Invalid Credentials:', findRichText: true),
      findsOneWidget,
    );
    final error = AppTheme.light.colorScheme.error;
    expect(_enabledBorderColors(tester), [error, error]);

    await tester.enterText(find.byType(TextField).at(0), 'a@b.co');
    await tester.pump();
    expect(
      find.textContaining('Invalid Credentials:', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('network failure shows connection banner, fields not red', (
    tester,
  ) async {
    await _pump(tester, failure: const AuthFailure(AuthFailureType.network));
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Connection error:', findRichText: true),
      findsOneWidget,
    );
    final error = AppTheme.light.colorScheme.error;
    expect(_enabledBorderColors(tester).contains(error), isFalse);
  });

  testWidgets(
    'shows loader while pending; success does not navigate by itself',
    (tester) async {
      final pending = Completer<void>();
      await _pump(tester, pending: pending);
      await _fillAndSubmit(tester);
      expect(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      pending.complete();
      await tester.pumpAndSettle();
      // Where to go next is the router's job (auth redirect), not the screen's.
      expect(find.text('HOME PAGE'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('Sign up navigates to sign up page', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('SIGN UP PAGE'), findsOneWidget);
  });

  testWidgets('Forgot password navigates to forgot page', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('FORGOT PAGE'), findsOneWidget);
  });

  testWidgets('Arabic renders without exceptions', (tester) async {
    await _pump(tester, rtl: true);
    expect(find.text('مرحبًا بعودتك'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders without exceptions', (tester) async {
    await _pump(tester, dark: true);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen does not overflow', (tester) async {
    await _pump(
      tester,
      failure: const AuthFailure(AuthFailureType.invalidCredentials),
    );
    tester.view.physicalSize = const Size(390, 600);
    await tester.pumpAndSettle();
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AppTextField), findsNWidgets(2));
  });
}
