import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';
import 'package:found_it/features/explore/view/ui/widgets/filters_bottom_sheet.dart';

import '../../../../../helpers/test_app.dart';

const _categories = [
  CategoryOption(
    id: 'cat-electronics',
    nameEn: 'Electronics',
    nameAr: 'إلكترونيات',
  ),
  CategoryOption(id: 'cat-wallets', nameEn: 'Wallets', nameAr: 'محافظ'),
  CategoryOption(id: 'cat-bags', nameEn: 'Bags', nameAr: 'حقائب'),
];

const _areas = [
  AreaOption(id: 'area-zamalek', nameEn: 'Zamalek', nameAr: 'الزمالك'),
  AreaOption(id: 'area-maadi', nameEn: 'Maadi', nameAr: 'المعادي'),
];

ExploreFilters? _result;

Future<void> _openSheet(WidgetTester tester, {bool rtl = false}) async {
  _result = null;

  await pumpTestApp(
    tester,
    Builder(
      builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () async {
            _result = await showModalBottomSheet<ExploreFilters>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const FiltersBottomSheet(
                categories: _categories,
                areas: _areas,
                cityName: 'Cairo',
              ),
            );
          },
          child: const Text('OPEN'),
        ),
      ),
    ),
    rtl: rtl,
  );

  await tester.tap(find.text('OPEN'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows dynamic categories, areas and the city name', (
    tester,
  ) async {
    await _openSheet(tester);

    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);
    expect(find.text('Bags'), findsOneWidget);
    expect(find.text('Zamalek'), findsOneWidget);
    expect(find.text('Maadi'), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Show results'), findsOneWidget);
  });

  testWidgets('returns the selected type, categories and areas', (
    tester,
  ) async {
    await _openSheet(tester);

    await tester.tap(find.text('Lost'));
    await tester.tap(find.text('Electronics'));
    await tester.tap(find.text('Bags'));
    await tester.tap(find.text('Zamalek'));
    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(_result, isNotNull);
    expect(_result!.type, ReportType.lost);
    expect(_result!.categoryIds, containsAll(['cat-electronics', 'cat-bags']));
    expect(_result!.areaIds, ['area-zamalek']);
  });

  testWidgets('Reset clears every selection', (tester) async {
    await _openSheet(tester);

    await tester.tap(find.text('Found'));
    await tester.tap(find.text('Wallets'));
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show results'));
    await tester.pumpAndSettle();

    expect(_result, isNotNull);
    expect(_result!.type, isNull);
    expect(_result!.categoryIds, isEmpty);
    expect(_result!.areaIds, isEmpty);
    expect(_result!.dateFrom, isNull);
    expect(_result!.dateTo, isNull);
  });

  testWidgets('renders in RTL without overflowing', (tester) async {
    await _openSheet(tester, rtl: true);

    expect(find.text('الفلاتر'), findsOneWidget);
    expect(find.text('إلكترونيات'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
