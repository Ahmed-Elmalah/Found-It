import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/onboarding/domain/complete_onboarding_use_case.dart';
import 'package:found_it/features/onboarding/domain/onboarding_repository.dart';
import 'package:found_it/features/onboarding/view/cubit/onboarding_cubit.dart';
import 'package:found_it/features/onboarding/view/ui/onboarding_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeRepo implements OnboardingRepository {
  int completeCalls = 0;

  @override
  bool isFirstLaunch() => true;

  @override
  Future<void> completeOnboarding() async => completeCalls++;
}

Future<_FakeRepo> _pump(
  WidgetTester tester, {
  bool dark = false,
  bool rtl = false,
}) async {
  final repo = _FakeRepo();
  final cubit = OnboardingCubit(CompleteOnboardingUseCase(repo));
  addTearDown(cubit.close);
  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) =>
            BlocProvider.value(value: cubit, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const Text('LOGIN PAGE'),
      ),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('page 1 shows title, Skip and Next', (tester) async {
    await _pump(tester);
    expect(find.text('Find what you lost'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('Next moves through pages to Get started', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Report what you found'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Chat and get it back'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Skip').hitTestable(), findsNothing);
  });

  testWidgets('Get started completes and goes to login', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
    expect(repo.completeCalls, 1);
  });

  testWidgets('Skip completes and goes to login', (tester) async {
    final repo = await _pump(tester);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN PAGE'), findsOneWidget);
    expect(repo.completeCalls, 1);
  });

  testWidgets('swiping moves to page 2', (tester) async {
    await _pump(tester);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Report what you found'), findsOneWidget);
  });

  testWidgets('Arabic renders without exceptions', (tester) async {
    await _pump(tester, rtl: true);
    expect(find.text('ابحث عمّا فقدته'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders without exceptions', (tester) async {
    await _pump(tester, dark: true);
    expect(find.text('Find what you lost'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
