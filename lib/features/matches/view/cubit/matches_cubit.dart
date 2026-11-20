import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/matches/domain/entities/matches_failure.dart';
import 'package:found_it/features/matches/domain/use_cases/get_match_details_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_count_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/get_my_matches_use_case.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';

class MatchesCubit extends Cubit<MatchesState> {
  final GetMyMatchesUseCase getMyMatches;
  final GetMatchDetailsUseCase getMatchDetails;
  final RejectMatchUseCase rejectMatch;
  final GetMyMatchesCountUseCase getMyMatchesCount;

  MatchesCubit({
    required this.getMyMatches,
    required this.getMatchDetails,
    required this.rejectMatch,
    required this.getMyMatchesCount,
  }) : super(const MatchesInitial());

  Future<void> loadMatches({String? reportId}) async {
    emit(const MatchesLoading());

    try {
      final matches = await getMyMatches(reportId: reportId);
      emit(MatchesLoaded(matches));
    } on MatchesFailure catch (f) {
      emit(MatchesError(f.type, f.message));
    } catch (e) {
      emit(MatchesError(MatchesFailureType.unknown, e.toString()));
    }
  }

  Future<void> dismissMatch(String matchId) async {
    final currentState = state;
    if (currentState is! MatchesLoaded) return;

    // Optimistically remove from list
    final previousMatches = currentState.matches;
    final updatedMatches =
        previousMatches.where((m) => m.matchId != matchId).toList();
    emit(currentState.copyWith(
      matches: updatedMatches,
      dismissingMatchId: matchId,
    ));

    try {
      await rejectMatch(matchId);
      emit(currentState.copyWith(
        matches: updatedMatches,
        clearDismissing: true,
      ));
    } on MatchesFailure catch (f) {
      // Revert optimistic update on failure
      emit(MatchesLoaded(previousMatches));
      emit(MatchesError(f.type, f.message));
    } catch (e) {
      emit(MatchesLoaded(previousMatches));
      emit(MatchesError(MatchesFailureType.unknown, e.toString()));
    }
  }

  Future<void> loadDetails(String matchId) async {
    emit(const MatchesLoading());

    try {
      final match = await getMatchDetails(matchId);
      emit(MatchDetailsLoaded(match));
    } on MatchesFailure catch (f) {
      emit(MatchesError(f.type, f.message));
    } catch (e) {
      emit(MatchesError(MatchesFailureType.unknown, e.toString()));
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
