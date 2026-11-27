import 'package:equatable/equatable.dart';

import 'package:found_it/features/claim/domain/entities/claim_failure.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';

enum ClaimStatus {
  initial,

  /// Fetching the questions.
  loading,

  /// Questions loaded; the user can pick answers.
  ready,

  /// Sending every answer to `submit_claim_answers`.
  submitting,

  /// All answers correct; the chat is open.
  passed,

  /// A wrong answer: the match is closed and the user is blocked.
  failed,

  /// Loading the questions failed (retry reloads).
  loadFailure,

  /// Submitting failed (network/server). Answers are kept so a retry costs
  /// nothing.
  submitFailure,
}

class ClaimState extends Equatable {
  const ClaimState({
    this.status = ClaimStatus.initial,
    this.matchId = '',
    this.questions = const [],
    this.choices = const {},
    this.failure,
    this.passedMatchId,
  });

  final ClaimStatus status;

  final String matchId;

  /// Ordered by [ClaimQuestionEntity.position].
  final List<ClaimQuestionEntity> questions;

  /// `questionId -> 0-based option index`.
  final Map<String, int> choices;

  final ClaimFailure? failure;

  /// Match to open once [status] is [ClaimStatus.passed].
  final String? passedMatchId;

  bool get hasQuestions => questions.isNotEmpty;

  bool get allAnswered =>
      hasQuestions && questions.every((q) => choices.containsKey(q.id));

  int get answeredCount =>
      questions.where((q) => choices.containsKey(q.id)).length;

  bool get isSubmitting => status == ClaimStatus.submitting;

  /// Submit is only possible with a loaded set whose answers are complete
  /// (including after a transient submit failure so the user can retry).
  bool get canSubmit =>
      allAnswered &&
      !isSubmitting &&
      (status == ClaimStatus.ready || status == ClaimStatus.submitFailure);

  int? choiceFor(String questionId) => choices[questionId];

  ClaimState copyWith({
    ClaimStatus? status,
    String? matchId,
    List<ClaimQuestionEntity>? questions,
    Map<String, int>? choices,
    ClaimFailure? failure,
    String? passedMatchId,
    bool clearFailure = false,
  }) {
    return ClaimState(
      status: status ?? this.status,
      matchId: matchId ?? this.matchId,
      questions: questions ?? this.questions,
      choices: choices ?? this.choices,
      failure: clearFailure ? null : (failure ?? this.failure),
      passedMatchId: passedMatchId ?? this.passedMatchId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    matchId,
    questions,
    choices,
    failure,
    passedMatchId,
  ];
}
