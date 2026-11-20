import 'package:found_it/features/matches/domain/entities/match_entity.dart';

abstract class MatchesRepository {
  Future<List<MatchEntity>> getMyMatches({String? reportId});
  Future<MatchEntity> getMatchDetails(String matchId);
  Future<void> rejectMatch(String matchId);
  Future<int> getMyMatchesCount();
}
