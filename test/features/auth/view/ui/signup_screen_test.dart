import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/auth_repository.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/signup_use_case.dart';
import 'package:found_it/features/auth/view/cubit/sign_up_cubit.dart';
import 'package:found_it/features/auth/view/ui/signup_screen.dart';

import '../../../../helpers/test_app.dart';

class FakeAuthRepository implements AuthRepository {
  int signUpCalls = 0;
  SignUpParams? lastParams;
  AuthFailure? failure;
  Completer<void>? pending;

  @override
  bool hasActiveSession() => false;

  @override
  Future<void> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> signUp(SignUpParams params) async {
    signUpCalls++;
    lastParams = params;
    if (pending != null) await pending!.future;
    if (failure != null) throw failure!;
  }
}

/// Starts on a stand-in login page and pushes the sign up screen, like the
/// real app does.
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
  final cubit = SignUpCubit(SignUpUseCase(repo));
  addTearDown(cubit.close);
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
                onPressed: () => context.push(AppRoutes.signUp),
                child: const Text('GO SIGN UP'),
              ),
            ],
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (_, _) =>
            BlocProvider.value(value: cubit, child: const SignUpScreen()),
      ),
      GoRoute(path: AppRoutes.city, builder: (_, _) => const Text('CITY PAGE')),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
  await tester.tap(find.text('GO SIGN UP'));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String name = 'Ahmed Ali',
  String email = 'a@b.com',
  String phone = '010 1234 5678',
  String address = '',
  String password = 'secret123',
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), phone);
  await tester.enterText(fields.at(3), address);
  await tester.enterText(fields.at(4), password);
  await _tapCreate(tester);
}

Future<void> _tapCreate(WidgetTester tester) async {
  final button = find.widgetWithText(AppButton, 'Create account');
  await tester.ensureVisible(button);
  await tester.tap(button);
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
  testWidgets('shows title, labels and texts', (tester) async {
    await _pump(tester);
    for (final t in [
      'Create account',
      'Full name',
      'Email',
      'Phone number',
      'Address',
      'Password',
      'At least 8 characters',
      '+20',
      'Already have an account?',
      'Log in',
    ]) {
      expect(find.text(t), findsWidgets, reason: t);
    }
  });

  testWidgets('empty submit shows Required 4 times and does not call repo', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _tapCreate(tester);
    expect(find.text('Required'), findsNWidgets(4));
    expect(repo.signUpCalls, 0);
  });

  testWidgets('one char name shows name error', (tester) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester, name: 'A');
    expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    expect(repo.signUpCalls, 0);
  });

  testWidgets('invalid email shows error', (tester) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester, email: 'not-an-email');
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(repo.signUpCalls, 0);
  });

  testWidgets('invalid phone shows error', (tester) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester, phone: '13 1234 5678');
    expect(find.text('Enter a valid Egyptian mobile number'), findsOneWidget);
    expect(repo.signUpCalls, 0);
  });

  testWidgets('short password shows error', (tester) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester, password: '1234567');
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(repo.signUpCalls, 0);
  });

  testWidgets('valid input normalizes phone, nulls address, goes to city', (
    tester,
  ) async {
    final repo = await _pump(tester);
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(repo.signUpCalls, 1);
    expect(repo.lastParams!.fullName, 'Ahmed Ali');
    expect(repo.lastParams!.email, 'a@b.com');
    expect(repo.lastParams!.phone, '+201012345678');
    expect(repo.lastParams!.address, isNull);
    expect(repo.lastParams!.password, 'secret123');
    expect(find.text('CITY PAGE'), findsOneWidget);
  });

  testWidgets(
    'email already in use: banner, only email is red, typing clears',
    (tester) async {
      await _pump(
        tester,
        failure: const AuthFailure(AuthFailureType.emailAlreadyInUse),
      );
      await _fillAndSubmit(tester);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Registration Failed:', findRichText: true),
        findsOneWidget,
      );
      final error = AppTheme.light.colorScheme.error;
      final colors = _enabledBorderColors(tester);
      expect(colors[1], error);
      expect(colors[0], isNot(error));
      expect(colors.where((c) => c == error).length, 1);

      await tester.enterText(find.byType(TextField).at(1), 'a@b.co');
      await tester.pump();
      expect(
        find.textContaining('Registration Failed:', findRichText: true),
        findsNothing,
      );
    },
  );

  testWidgets('network failure shows connection banner', (tester) async {
    await _pump(tester, failure: const AuthFailure(AuthFailureType.network));
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Connection error:', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('shows loader while pending, then goes to city on success', (
    tester,
  ) async {
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
    expect(find.text('CITY PAGE'), findsOneWidget);
  });

  testWidgets('back button returns to login page', (tester) async {
    await _pump(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });

  testWidgets('Log in footer returns to login page', (tester) async {
    await _pump(tester);
    final link = find.text('Log in');
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
  });

  testWidgets('Arabic renders without exceptions', (tester) async {
    await _pump(tester, rtl: true);
    expect(find.text('إنشاء حساب'), findsWidgets);
    expect(find.text('الاسم الكامل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders without exceptions', (tester) async {
    await _pump(tester, dark: true);
    expect(find.text('Create account'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screen does not overflow', (tester) async {
    await _pump(
      tester,
      failure: const AuthFailure(AuthFailureType.emailAlreadyInUse),
    );
    tester.view.physicalSize = const Size(390, 600);
    await tester.pumpAndSettle();
    await _fillAndSubmit(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AppTextField), findsNWidgets(5));
  });
}
