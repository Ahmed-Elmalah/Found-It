import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';

class GetMyMatchesUseCase {
  final MatchesRepository repository;

  const GetMyMatchesUseCase(this.repository);

  Future<List<MatchEntity>> call({String? reportId}) =>
      repository.getMyMatches(reportId: reportId);
}
