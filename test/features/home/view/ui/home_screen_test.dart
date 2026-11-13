import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/home/view/ui/home_screen.dart';
import 'package:found_it/features/home/view/widgets/city_selection_bottom_sheet.dart';
import 'package:found_it/features/home/view/widgets/home_empty_view.dart';
import 'package:found_it/features/home/view/widgets/home_error_view.dart';
import 'package:found_it/features/home/view/widgets/home_feed_item_card.dart';
import 'package:found_it/features/home/view/widgets/home_header.dart';
import 'package:found_it/features/home/view/widgets/home_hero_banner.dart';
import 'package:found_it/features/home/view/widgets/home_shimmer_view.dart';
import 'package:found_it/features/home/view/widgets/home_success_view.dart';
import '../../../../helpers/test_app.dart';

void main() {
  testWidgets('renders HomeScreen initial Success state with header, hero banner and feed cards',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Cairo',
        initialState: HomeViewState.success,
      ),
      padded: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeHeader), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.byType(HomeHeroBanner), findsOneWidget);
    expect(find.byType(HomeSuccessView), findsOneWidget);
    expect(find.byType(HomeFeedItemCard), findsWidgets);
  });

  testWidgets('switches to Loading state and renders HomeShimmerView',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Cairo',
        initialState: HomeViewState.loading,
      ),
      padded: false,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomeShimmerView), findsOneWidget);
  });

  testWidgets('switches to Empty state and renders HomeEmptyView with CTA',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Alexandria',
        initialState: HomeViewState.empty,
      ),
      padded: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeEmptyView), findsOneWidget);
    expect(find.text('No reports yet in Alexandria'), findsOneWidget);
    expect(find.text('Create first report'), findsOneWidget);
  });

  testWidgets('switches to Error state and renders HomeErrorView with Retry',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Cairo',
        initialState: HomeViewState.error,
      ),
      padded: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeErrorView), findsOneWidget);
    expect(find.text('Unable to load reports'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('renders Arabic texts and RTL layout in HomeScreen',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'القاهرة',
        initialState: HomeViewState.success,
      ),
      rtl: true,
      padded: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('القاهرة'), findsOneWidget);
    expect(find.text('عُثر عليه'), findsWidgets);
  });

  testWidgets('renders in Dark theme without exceptions', (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Cairo',
        initialState: HomeViewState.success,
      ),
      dark: true,
      padded: false,
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('tapping city in header opens CitySelectionBottomSheet and updates city',
      (tester) async {
    await pumpTestApp(
      tester,
      const HomeScreen(
        initialCityName: 'Cairo',
        initialState: HomeViewState.success,
      ),
      padded: false,
    );
    await tester.pumpAndSettle();

    // Tap city selector in header
    await tester.tap(find.text('Cairo'));
    await tester.pumpAndSettle();

    // Verify CitySelectionBottomSheet is shown
    expect(find.byType(CitySelectionBottomSheet), findsOneWidget);
    expect(find.text('Alexandria'), findsOneWidget);

    // Tap Alexandria
    await tester.tap(find.text('Alexandria'));
    await tester.pumpAndSettle();

    // Verify bottom sheet dismissed and new city is set in header
    expect(find.byType(CitySelectionBottomSheet), findsNothing);
    expect(find.text('Alexandria'), findsWidgets);
  });
}
