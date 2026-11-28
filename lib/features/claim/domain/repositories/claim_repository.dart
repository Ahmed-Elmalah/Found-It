import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';

abstract interface class ClaimRepository {
  /// `get_claim_questions(p_match_id)` — questions without their answers.
  Future<List<ClaimQuestionEntity>> getClaimQuestions(String matchId);

  /// `submit_claim_answers(p_match_id, p_answers)` — one chance only.
  Future<ClaimSubmissionResult> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  );
}
