import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/claim/data/models/claim_question_model.dart';
import 'package:found_it/features/claim/data/models/claim_submission_model.dart';
import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';

/// All Supabase access for ownership verification lives here. Cubits and
/// screens never import `supabase_flutter`.
abstract interface class ClaimRemoteDataSource {
  /// `get_claim_questions(p_match_id)` (Section 10).
  Future<List<ClaimQuestionModel>> getClaimQuestions(String matchId);

  /// `submit_claim_answers(p_match_id, p_answers)` (Section 10).
  Future<ClaimSubmissionModel> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  );
}

class ClaimRemoteDataSourceImpl implements ClaimRemoteDataSource {
  const ClaimRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<ClaimQuestionModel>> getClaimQuestions(String matchId) async {
    final res = await _supabase.rpc(
      'get_claim_questions',
      params: {'p_match_id': matchId},
    );

    if (res == null) return const [];
    return (res as List)
        .map((row) => ClaimQuestionModel.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ClaimSubmissionModel> submitClaimAnswers(
    String matchId,
    List<ClaimAnswerEntity> answers,
  ) async {
    final res = await _supabase.rpc(
      'submit_claim_answers',
      params: {
        'p_match_id': matchId,
        'p_answers': [
          for (final answer in answers)
            {'question_id': answer.questionId, 'choice': answer.choice},
        ],
      },
    );

    return ClaimSubmissionModel.fromJson(res as Map<String, dynamic>);
  }
}
