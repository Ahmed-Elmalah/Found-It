import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/data/mock/explore_mock_data.dart';

void main() {
  test('returns every report newest first by default', () {
    final results = ExploreMockData.search();

    expect(results, hasLength(ExploreMockData.reports.length));
    for (var i = 1; i < results.length; i++) {
      expect(results[i - 1].itemDate.isBefore(results[i].itemDate), isFalse);
    }
  });

  test('query searches the title and the description', () {
    final byTitle = ExploreMockData.search(query: 'airpods');
    expect(byTitle.map((r) => r.title), contains('AirPods Pro, white case'));

    final byDescription = ExploreMockData.search(query: 'metro');
    expect(
      byDescription.map((r) => r.title),
      containsAll(['Black leather wallet', 'AirPods Pro, white case']),
    );
  });

  test('category filter keeps only that category', () {
    final results = ExploreMockData.search(categoryId: 'cat-bags');

    expect(results, isNotEmpty);
    expect(results.every((r) => r.categoryId == 'cat-bags'), isTrue);
  });

  test('date range is inclusive', () {
    final results = ExploreMockData.search(
      dateFrom: DateTime(2026, 11, 3),
      dateTo: DateTime(2026, 11, 5),
    );

    expect(results, isNotEmpty);
    expect(
      results.every(
        (r) =>
            !r.itemDate.isBefore(DateTime(2026, 11, 3)) &&
            !r.itemDate.isAfter(DateTime(2026, 11, 5)),
      ),
      isTrue,
    );
  });

  test('filters combine and can return an empty list', () {
    final results = ExploreMockData.search(
      query: 'phone',
      categoryId: 'cat-wallets',
    );

    expect(results, isEmpty);
  });

  test('mock types are a realistic mix of lost and found', () {
    final types = ExploreMockData.reports.map((r) => r.type).toSet();
    expect(types, containsAll([ReportType.lost, ReportType.found]));
  });
}
