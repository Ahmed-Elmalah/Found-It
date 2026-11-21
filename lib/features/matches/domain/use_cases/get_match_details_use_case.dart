import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';

class GetMatchDetailsUseCase {
  final MatchesRepository repository;

  const GetMatchDetailsUseCase(this.repository);

  Future<MatchEntity> call(String matchId) =>
      repository.getMatchDetails(matchId);
}
