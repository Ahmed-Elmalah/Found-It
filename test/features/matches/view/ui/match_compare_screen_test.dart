import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/view/ui/match_compare_screen.dart';
import 'package:found_it/features/matches/view/widgets/comparison_field_row.dart';
import 'package:found_it/features/matches/view/widgets/private_details_banner.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('MatchCompareScreen Widget Tests', () {
    final mockMatch = MatchEntity(
      matchId: 'match_123',
      status: 'potential',
      similarity: 88,
      source: 'auto',
      ownershipVerified: false,
      iAmFinder: false,
      createdAt: DateTime.now(),
      otherUserName: 'Omar S.',
      myReport: MatchReportSummary(
        id: 'rep_1',
        refCode: 'RPT-1001',
        type: 'lost',
        title: 'MacBook Pro 14"',
        description: 'Silver M2 Pro, small scratch on top',
        categoryNameEn: 'Electronics',
        categoryNameAr: 'إلكترونيات',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaNameEn: 'Nasr City',
        areaNameAr: 'مدينة نصر',
        itemDate: DateTime(2026, 11, 10),
        status: 'matching',
      ),
      otherReport: MatchReportSummary(
        id: 'rep_2',
        refCode: 'RPT-1002',
        type: 'found',
        title: 'Found Apple Laptop in Cafe',
        description: 'Found on table 4, locked with password',
        categoryNameEn: 'Electronics',
        categoryNameAr: 'إلكترونيات',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaNameEn: 'Nasr City',
        areaNameAr: 'مدينة نصر',
        itemDate: DateTime(2026, 11, 11),
        status: 'matching',
      ),
    );

    testWidgets('renders comparison header, private details banner and rows',
        (tester) async {
      await pumpTestApp(
        tester,
        MatchCompareScreen(match: mockMatch),
        padded: false,
      );

      expect(find.text('Match comparison'), findsOneWidget);
      expect(find.text('88% Match'), findsOneWidget);
      expect(find.byType(PrivateDetailsBanner), findsOneWidget);
      expect(find.byType(ComparisonFieldRow), findsWidgets);
      expect(find.text('Your report'), findsOneWidget);
      expect(find.text('Matched report'), findsOneWidget);
      expect(find.text('Start chat'), findsOneWidget);
      expect(find.text('Not my item'), findsOneWidget);
    });

    testWidgets('triggers onStartChat and onNotMyItem callbacks', (tester) async {
      var chatStarted = false;
      var notMyItemTapped = false;

      await pumpTestApp(
        tester,
        MatchCompareScreen(
          match: mockMatch,
          onStartChat: () => chatStarted = true,
          onNotMyItem: () => notMyItemTapped = true,
        ),
        padded: false,
      );

      await tester.tap(find.text('Start chat'));
      await tester.pump();
      expect(chatStarted, isTrue);

      await tester.tap(find.text('Not my item'));
      await tester.pump();
      expect(notMyItemTapped, isTrue);
    });
  });
}
