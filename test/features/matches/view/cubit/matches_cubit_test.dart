import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/domain/entities/matches_failure.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';

class _FakeMatchesRepository implements MatchesRepository {
  bool shouldFailMatches = false;
  bool shouldFailDetails = false;
  bool shouldFailReject = false;
  bool shouldFailCount = false;

  String? rejectedMatchId;
  String? queriedReportId;

  final sampleMatch = MatchEntity(
    matchId: 'match_1',
    status: 'potential',
    similarity: 90,
    source: 'auto',
    ownershipVerified: false,
    iAmFinder: false,
    createdAt: DateTime(2026, 11, 20),
    otherUserName: 'Sara N.',
    myReport: MatchReportSummary(
      id: 'rep_1',
      refCode: 'RPT-1001',
      type: 'lost',
      title: 'Black Backpack',
      categoryNameEn: 'Bags',
      categoryNameAr: 'حقائب',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 15),
      status: 'matching',
    ),
    otherReport: MatchReportSummary(
      id: 'rep_2',
      refCode: 'RPT-1002',
      type: 'found',
      title: 'Found Backpack in Metro',
      categoryNameEn: 'Bags',
      categoryNameAr: 'حقائب',
      cityNameEn: 'Cairo',
      cityNameAr: 'القاهرة',
      areaNameEn: 'Maadi',
      areaNameAr: 'المعادي',
      itemDate: DateTime(2026, 11, 16),
      status: 'matching',
    ),
  );

  @override
  Future<List<MatchEntity>> getMyMatches({String? reportId}) async {
    if (shouldFailMatches) {
      throw const MatchesFailure(MatchesFailureType.network);
    }
    queriedReportId = reportId;
    return [sampleMatch];
  }

  @override
  Future<MatchEntity> getMatchDetails(String matchId) async {
    if (shouldFailDetails) {
      throw const MatchesFailure(MatchesFailureType.notFound);
    }
    return sampleMatch;
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    if (shouldFailReject) {
      throw const MatchesFailure(MatchesFailureType.invalidState);
    }
    rejectedMatchId = matchId;
  }

  @override
  Future<int> getMyMatchesCount() async {
    if (shouldFailCount) {
      throw const MatchesFailure(MatchesFailureType.network);
    }
    return 3;
  }
}

void main() {
  group('MatchesCubit Tests', () {
    late _FakeMatchesRepository repo;
    late MatchesCubit cubit;

    setUp(() {
      repo = _FakeMatchesRepository();
      cubit = MatchesCubit(
        getMyMatches: GetMyMatchesUseCase(repo),
        getMatchDetails: GetMatchDetailsUseCase(repo),
        rejectMatchUseCase: RejectMatchUseCase(repo),
        getMyMatchesCount: GetMyMatchesCountUseCase(repo),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is MatchesInitial', () {
      expect(cubit.state, const MatchesInitial());
    });

    test('loadMatches loads matches successfully into MatchesLoaded state',
        () async {
      await cubit.loadMatches();

      expect(cubit.state, isA<MatchesLoaded>());
      final loaded = cubit.state as MatchesLoaded;
      expect(loaded.matches, [repo.sampleMatch]);
    });

    test('loadMatches emits MatchesError when repository fails', () async {
      repo.shouldFailMatches = true;

      await cubit.loadMatches();

      expect(cubit.state, isA<MatchesError>());
      final error = cubit.state as MatchesError;
      expect(error.failureType, MatchesFailureType.network);
    });

    test('dismissMatch optimistically removes match and calls rejectMatch',
        () async {
      await cubit.loadMatches();
      expect((cubit.state as MatchesLoaded).matches, isNotEmpty);

      final success = await cubit.dismissMatch('match_1');

      expect(success, isTrue);
      expect(repo.rejectedMatchId, 'match_1');
      expect(cubit.state, isA<MatchesLoaded>());
      final loaded = cubit.state as MatchesLoaded;
      expect(loaded.matches, isEmpty);
      expect(loaded.dismissingMatchId, isNull);
    });

    test('dismissMatch reverts list on failure without emitting MatchesError',
        () async {
      await cubit.loadMatches();
      repo.shouldFailReject = true;

      final success = await cubit.dismissMatch('match_1');

      expect(success, isFalse);
      expect(cubit.state, isA<MatchesLoaded>());
      final loaded = cubit.state as MatchesLoaded;
      expect(loaded.matches, [repo.sampleMatch]);
    });

    test('setMatchDetails sets MatchDetailsLoaded state directly', () {
      cubit.setMatchDetails(repo.sampleMatch);

      expect(cubit.state, isA<MatchDetailsLoaded>());
      final loaded = cubit.state as MatchDetailsLoaded;
      expect(loaded.match, repo.sampleMatch);
    });

    test('rejectMatch delegates to dismissMatch and calls reject', () async {
      final success = await cubit.rejectMatch('match_1');

      expect(success, isTrue);
      expect(repo.rejectedMatchId, 'match_1');
    });

    test('loadDetails loads match details successfully', () async {
      await cubit.loadDetails('match_1');

      expect(cubit.state, isA<MatchDetailsLoaded>());
      final loaded = cubit.state as MatchDetailsLoaded;
      expect(loaded.match, repo.sampleMatch);
    });

    test('getNewMatchesCount returns count or 0 on failure', () async {
      final count = await cubit.getNewMatchesCount();
      expect(count, 3);

      repo.shouldFailCount = true;
      final failedCount = await cubit.getNewMatchesCount();
      expect(failedCount, 0);
    });
  });
}
