import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/ui/match_compare_screen.dart';
import 'package:found_it/features/matches/view/widgets/comparison_field_row.dart';
import 'package:found_it/features/matches/view/widgets/private_details_banner.dart';

import '../../../../helpers/test_app.dart';

class _FakeMatchesRepo implements MatchesRepository {
  final MatchEntity match;
  _FakeMatchesRepo(this.match);

  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async => [match];

  @override
  Future<MatchEntity> getMatchDetails(String matchId) async => match;

  @override
  Future<void> rejectMatch(String matchId) async {}

  @override
  Future<int> getMyMatchesCount() async => 1;
}

void main() {
  group('MatchCompareScreen Widget Tests', () {
    late _FakeMatchesRepo fakeRepo;
    late MatchesCubit cubit;

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

    setUp(() {
      fakeRepo = _FakeMatchesRepo(mockMatch);
      cubit = MatchesCubit(
        getMyMatches: GetMyMatchesUseCase(fakeRepo),
        getMatchDetails: GetMatchDetailsUseCase(fakeRepo),
        rejectMatchUseCase: RejectMatchUseCase(fakeRepo),
        getMyMatchesCount: GetMyMatchesCountUseCase(fakeRepo),
      )..setMatchDetails(mockMatch);
    });

    tearDown(() async {
      await cubit.close();
    });

    Widget wrapWithCubit(Widget child) {
      return BlocProvider<MatchesCubit>.value(
        value: cubit,
        child: child,
      );
    }

    testWidgets('renders comparison header, private details banner and rows',
        (tester) async {
      await pumpTestApp(
        tester,
        wrapWithCubit(MatchCompareScreen(match: mockMatch)),
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

    testWidgets('triggers onStartChat and onNotMyItem callbacks',
        (tester) async {
      var chatStarted = false;
      var notMyItemTapped = false;

      await pumpTestApp(
        tester,
        wrapWithCubit(
          MatchCompareScreen(
            match: mockMatch,
            onStartChat: () => chatStarted = true,
            onNotMyItem: () => notMyItemTapped = true,
          ),
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

    testWidgets('loads and renders comparison when only matchId is provided',
        (tester) async {
      await pumpTestApp(
        tester,
        wrapWithCubit(const MatchCompareScreen(matchId: 'match_123')),
        padded: false,
      );

      expect(find.text('Match comparison'), findsOneWidget);
      expect(find.text('88% Match'), findsOneWidget);
      expect(find.text('MacBook Pro 14"'), findsOneWidget);
    });
  });
}
