import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/view/ui/potential_matches_screen.dart';
import 'package:found_it/features/matches/view/widgets/match_card.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('PotentialMatchesScreen Widget Tests', () {
    final mockMatch = MatchEntity(
      matchId: 'match_123',
      status: 'potential',
      similarity: 92,
      source: 'auto',
      ownershipVerified: false,
      iAmFinder: false,
      createdAt: DateTime.now(),
      otherUserName: 'Mona K.',
      myReport: MatchReportSummary(
        id: 'rep_1',
        refCode: 'RPT-1001',
        type: 'lost',
        title: 'Black Leather Wallet',
        categoryNameEn: 'Wallets',
        categoryNameAr: 'محافظ',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaNameEn: 'Maadi',
        areaNameAr: 'المعادي',
        itemDate: DateTime(2026, 11, 1),
        status: 'matching',
      ),
      otherReport: MatchReportSummary(
        id: 'rep_2',
        refCode: 'RPT-1002',
        type: 'found',
        title: 'Brown Leather Wallet with IDs',
        categoryNameEn: 'Wallets',
        categoryNameAr: 'محافظ',
        cityNameEn: 'Cairo',
        cityNameAr: 'القاهرة',
        areaNameEn: 'Maadi',
        areaNameAr: 'المعادي',
        itemDate: DateTime(2026, 11, 2),
        status: 'matching',
      ),
    );

    testWidgets('shows empty state when no matches exist', (tester) async {
      await pumpTestApp(
        tester,
        const PotentialMatchesScreen(initialMatches: []),
        padded: false,
      );

      expect(find.text('No potential matches yet'), findsOneWidget);
      expect(
        find.textContaining('We\'ll notify you automatically'),
        findsOneWidget,
      );
    });

    testWidgets('renders match card with similarity % and action buttons',
        (tester) async {
      await pumpTestApp(
        tester,
        PotentialMatchesScreen(initialMatches: [mockMatch]),
        padded: false,
      );

      expect(find.byType(MatchCard), findsOneWidget);
      expect(find.text('92% Match'), findsOneWidget);
      expect(find.text('Brown Leather Wallet with IDs'), findsOneWidget);
      expect(find.text('View match'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('dismissing a match removes it from the list', (tester) async {
      await pumpTestApp(
        tester,
        PotentialMatchesScreen(initialMatches: [mockMatch]),
        padded: false,
      );

      expect(find.byType(MatchCard), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.byType(MatchCard), findsNothing);
      expect(find.text('Match dismissed'), findsOneWidget);
    });

    testWidgets('tapping "View match" navigates to matchCompare route',
        (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.potentialMatches,
        routes: [
          GoRoute(
            path: AppRoutes.potentialMatches,
            builder: (_, _) => PotentialMatchesScreen(
              initialMatches: [mockMatch],
            ),
          ),
          GoRoute(
            path: AppRoutes.matchCompare,
            builder: (_, state) => const Scaffold(
              body: Text('COMPARE SCREEN'),
            ),
          ),
        ],
      );

      await pumpTestRouterApp(tester, router);

      await tester.tap(find.text('View match'));
      await tester.pumpAndSettle();

      expect(find.text('COMPARE SCREEN'), findsOneWidget);
    });
  });
}
