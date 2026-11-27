import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';
import 'package:found_it/features/claim/domain/repositories/claim_repository.dart';

class SubmitClaimAnswersUseCase {
  const SubmitClaimAnswersUseCase(this._repository);

  final ClaimRepository _repository;

  Future<ClaimSubmissionResult> call(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) => _repository.submitClaimAnswers(matchId, answers);
}
