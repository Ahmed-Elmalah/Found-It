import 'package:found_it/features/matches/domain/repositories/matches_repository.dart';

class GetMyMatchesCountUseCase {
  final MatchesRepository repository;

  const GetMyMatchesCountUseCase(this.repository);

  Future<int> call() => repository.getMyMatchesCount();
}
