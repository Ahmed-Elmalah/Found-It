import 'package:equatable/equatable.dart';

import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/matches_failure.dart';

sealed class MatchesState extends Equatable {
  const MatchesState();

  @override
  List<Object?> get props => [];
}

final class MatchesInitial extends MatchesState {
  const MatchesInitial();
}

final class MatchesLoading extends MatchesState {
  const MatchesLoading();
}

final class MatchesLoaded extends MatchesState {
  final List<MatchEntity> matches;
  final String? dismissingMatchId;

  const MatchesLoaded(this.matches, {this.dismissingMatchId});

  MatchesLoaded copyWith({
    List<MatchEntity>? matches,
    String? dismissingMatchId,
    bool clearDismissing = false,
  }) {
    return MatchesLoaded(
      matches ?? this.matches,
      dismissingMatchId:
          clearDismissing ? null : (dismissingMatchId ?? this.dismissingMatchId),
    );
  }

  @override
  List<Object?> get props => [matches, dismissingMatchId];
}

final class MatchDetailsLoaded extends MatchesState {
  final MatchEntity match;

  const MatchDetailsLoaded(this.match);

  @override
  List<Object?> get props => [match];
}

final class MatchesError extends MatchesState {
  final MatchesFailureType failureType;
  final String? message;

  const MatchesError(this.failureType, [this.message]);

  @override
  List<Object?> get props => [failureType, message];
}
