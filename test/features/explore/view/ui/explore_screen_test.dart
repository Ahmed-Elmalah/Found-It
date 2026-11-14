import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/constants/app_durations.dart';
import 'package:found_it/features/explore/domain/get_categories_use_case.dart';
import 'package:found_it/features/explore/domain/get_city_areas_use_case.dart';
import 'package:found_it/features/explore/domain/get_current_city_use_case.dart';
import 'package:found_it/features/explore/domain/search_reports_use_case.dart';
import 'package:found_it/features/explore/view/cubit/search_cubit.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';
import 'package:found_it/features/explore/view/ui/explore_screen.dart';

import '../../../../helpers/test_app.dart';
import '../../helpers/fake_explore_repository.dart';

Future<SearchCubit> _pump(
  WidgetTester tester, {
  FakeExploreRepository? repository,
  bool dark = false,
  bool rtl = false,
}) async {
  final repo = repository ?? FakeExploreRepository();
  final cubit = SearchCubit(
    getCurrentCity: GetCurrentCityUseCase(repo),
    searchReports: SearchReportsUseCase(repo),
    getCategories: GetCategoriesUseCase(repo),
    getCityAreas: GetCityAreasUseCase(repo),
  );

  final router = GoRouter(
    initialLocation: '/explore',
    routes: [
      GoRoute(
        path: '/explore',
        builder: (_, _) => BlocProvider(
          create: (_) => cubit..init(),
          child: const ExploreScreen(),
        ),
      ),
    ],
  );
  await pumpTestRouterApp(tester, router, dark: dark, rtl: rtl);
  await tester.pumpAndSettle();

  return cubit;
}

Future<void> _waitForDebounce(WidgetTester tester) async {
  await tester.pump(
    AppDurations.searchDebounce + const Duration(milliseconds: 20),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the title, count and loaded report cards', (tester) async {
    final cubit = await _pump(tester);

    expect(cubit.state.status, SearchStatus.success);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.textContaining('3 active reports'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
    expect(find.text('Black leather wallet'), findsOneWidget);
    expect(find.text('Lost'), findsWidgets);
    expect(find.text('Zamalek, Cairo'), findsWidgets);
    expect(find.text('Cairo'), findsOneWidget); // city chip
  });

  testWidgets('typing searches after the debounce', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'wallet');
    await _waitForDebounce(tester);

    expect(find.textContaining('1 active reports'), findsOneWidget);
    expect(find.text('Black leather wallet'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsNothing);
  });

  testWidgets('the filters sheet applies a category', (tester) async {
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Show results'), findsOneWidget);
    expect(find.text('Area / District'), findsOneWidget);

    await tester.tap(find.text('Bags'));
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(find.text('Bags'), findsOneWidget); // active filter chip
    expect(find.text('Brown leather handbag'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsNothing);
  });

  testWidgets('no matches shows the empty state and Clear filters resets', (
    tester,
  ) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField).first, 'zzzzz');
    await _waitForDebounce(tester);

    expect(find.text('No matching reports found.'), findsOneWidget);
    expect(find.text('Try adjusting your search filters.'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);

    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.textContaining('3 active reports'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
  });

  testWidgets('a failure shows Retry and retrying loads the reports', (
    tester,
  ) async {
    final repository = FakeExploreRepository()..shouldFail = true;
    await _pump(tester, repository: repository);

    expect(find.text("Couldn't load reports"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    repository.shouldFail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('3 active reports'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
  });

  testWidgets('renders in dark mode and RTL without overflowing', (
    tester,
  ) async {
    await _pump(tester, dark: true, rtl: true);

    expect(find.text('استكشاف'), findsOneWidget);
    expect(find.text('AirPods Pro, white case'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
