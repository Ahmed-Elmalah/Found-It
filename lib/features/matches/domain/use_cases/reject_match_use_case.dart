import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';

class RejectMatchUseCase {
  final MatchesRepository repository;

  const RejectMatchUseCase(this.repository);

  Future<void> call(String matchId) => repository.rejectMatch(matchId);
}
