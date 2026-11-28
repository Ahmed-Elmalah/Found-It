import 'package:equatable/equatable.dart';

/// One answer sent to `submit_claim_answers`.
///
/// [choice] is the 0-based index inside the question's `options` list
/// (Section 10), never the answer text.
class ClaimAnswerEntity extends Equatable {
  const ClaimAnswerEntity({required this.questionId, required this.choice});

  final String questionId;
  final int choice;

  @override
  List<Object?> get props => [questionId, choice];
}
