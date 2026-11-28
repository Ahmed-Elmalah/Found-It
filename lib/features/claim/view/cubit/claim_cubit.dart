import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/claim/domain/entities/claim_answer_entity.dart';
import 'package:found_it/features/claim/domain/entities/claim_failure.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';
import 'package:found_it/features/claim/domain/use_cases/get_claim_questions_use_case.dart';
import 'package:found_it/features/claim/domain/use_cases/submit_claim_answers_use_case.dart';
import 'package:found_it/features/claim/view/cubit/claim_state.dart';

/// Ownership verification (Story #6): load the finder's questions, track one
/// radio choice per question, then submit every answer in a single call.
///
/// One chance only: a wrong answer closes the match, so the cubit never
/// reveals which question failed. A network/server error is transient and
/// keeps the chosen answers for a retry.
class ClaimCubit extends Cubit<ClaimState> {
  ClaimCubit({
    required this.getClaimQuestions,
    required this.submitClaimAnswers,
  }) : super(const ClaimState());

  final GetClaimQuestionsUseCase getClaimQuestions;
  final SubmitClaimAnswersUseCase submitClaimAnswers;

  /// Loads `get_claim_questions` and starts a clean selection.
  Future<void> loadQuestions(String matchId) async {
    emit(ClaimState(status: ClaimStatus.loading, matchId: matchId));

    try {
      final questions = await getClaimQuestions(matchId);
      if (isClosed) return;

      final ordered = [...questions]
        ..sort((a, b) => a.position.compareTo(b.position));

      emit(
        ClaimState(
          status: ClaimStatus.ready,
          matchId: matchId,
          questions: ordered,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        ClaimState(
          status: ClaimStatus.loadFailure,
          matchId: matchId,
          failure: _toFailure(error),
        ),
      );
    }
  }

  /// Records the radio selection for one question.
  ///
  /// Ignored while loading/submitting or for unknown ids / out-of-range
  /// indexes, so a stale tap can never build an invalid payload.
  void selectAnswer(String questionId, int choice) {
    if (isClosed) return;
    if (state.status != ClaimStatus.ready &&
        state.status != ClaimStatus.submitFailure) {
      return;
    }

    ClaimQuestionEntity? question;
    for (final item in state.questions) {
      if (item.id == questionId) {
        question = item;
        break;
      }
    }
    if (question == null) return;
    if (choice < 0 || choice >= question.options.length) return;

    final choices = Map<String, int>.of(state.choices)..[questionId] = choice;
    emit(
      state.copyWith(
        status: ClaimStatus.ready,
        choices: choices,
        clearFailure: true,
      ),
    );
  }

  /// Sends every answer at once. Does nothing until all questions are answered
  /// and never double-submits.
  Future<void> submitAnswers() async {
    if (isClosed) return;
    if (!state.canSubmit) return;

    final questions = state.questions;
    final choices = state.choices;

    emit(state.copyWith(status: ClaimStatus.submitting, clearFailure: true));

    try {
      final answers = [
        for (final question in questions)
          ClaimAnswerEntity(
            questionId: question.id,
            choice: choices[question.id]!,
          ),
      ];

      final result = await submitClaimAnswers(state.matchId, answers);
      if (isClosed) return;

      emit(
        state.copyWith(
          status: result.passed ? ClaimStatus.passed : ClaimStatus.failed,
          passedMatchId: result.passed
              ? (result.matchId.isEmpty ? state.matchId : result.matchId)
              : null,
          clearFailure: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      // Transient: keep the selections so the user can simply retry.
      emit(
        state.copyWith(
          status: ClaimStatus.submitFailure,
          failure: _toFailure(error),
        ),
      );
    }
  }

  static ClaimFailure _toFailure(Object error) {
    if (error is ClaimFailure) return error;
    return const ClaimFailure(ClaimFailureType.unknown);
  }
}
