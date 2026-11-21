import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/matches_failure.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final GetMyMatchesUseCase getMyMatches;
  final GetMatchDetailsUseCase getMatchDetails;
  final RejectMatchUseCase rejectMatchUseCase;
  final GetMyMatchesCountUseCase getMyMatchesCount;

  MatchesCubit({
    required this.getMyMatches,
    required this.getMatchDetails,
    required this.rejectMatchUseCase,
    required this.getMyMatchesCount,
  }) : super(const MatchesInitial());

  Future<void> loadMatches({String? reportId}) async {
    emit(const MatchesLoading());

    try {
      final matches = await getMyMatches(reportId: reportId);
      emit(MatchesLoaded(matches));
    } on MatchesFailure catch (f) {
      emit(MatchesError(f.type, f.message));
    } catch (_) {
      emit(const MatchesError(MatchesFailureType.unknown));
    }
  }

  /// Sets match details directly into state (fast path when extra is provided).
  void setMatchDetails(MatchEntity match) {
    emit(MatchDetailsLoaded(match));
  }

  /// Dismisses a match optimistically.
  /// On failure, the list is reverted and kept in [MatchesLoaded] (no [MatchesError] is emitted).
  /// Returns `true` on success, `false` on failure.
  Future<bool> dismissMatch(String matchId) async {
    final currentState = state;
    if (currentState is MatchesLoaded) {
      // Optimistically remove from list
      final previousMatches = currentState.matches;
      final updatedMatches =
          previousMatches.where((m) => m.matchId != matchId).toList();
      emit(currentState.copyWith(
        matches: updatedMatches,
        dismissingMatchId: matchId,
      ));

      try {
        await rejectMatchUseCase(matchId);
        emit(currentState.copyWith(
          matches: updatedMatches,
          clearDismissing: true,
        ));
        return true;
      } catch (_) {
        // Revert optimistic update on failure - keep list intact!
        emit(MatchesLoaded(previousMatches));
        return false;
      }
    } else {
      try {
        await rejectMatchUseCase(matchId);
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  /// Rejects a match by id (for use by MatchCompareScreen).
  Future<bool> rejectMatch(String matchId) => dismissMatch(matchId);

  Future<void> loadDetails(String matchId) async {
    emit(const MatchesLoading());

    try {
      final match = await getMatchDetails(matchId);
      emit(MatchDetailsLoaded(match));
    } on MatchesFailure catch (f) {
      emit(MatchesError(f.type, f.message));
    } catch (_) {
      emit(const MatchesError(MatchesFailureType.unknown));
    }
  }

  Future<int> getNewMatchesCount() async {
    try {
      return await getMyMatchesCount();
    } catch (_) {
      return 0;
    }
  }
}
