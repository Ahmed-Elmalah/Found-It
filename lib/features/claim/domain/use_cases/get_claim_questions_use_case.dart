import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';

class GetClaimQuestionsUseCase {
  const GetClaimQuestionsUseCase(this._repository);

  final ClaimRepository _repository;

  Future<List<ClaimQuestionEntity>> call(String matchId) =>
      _repository.getClaimQuestions(matchId);
}
