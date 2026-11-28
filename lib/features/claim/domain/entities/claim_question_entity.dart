import 'package:equatable/equatable.dart';

/// One ownership-verification question shown to the person claiming an item
/// (Story #6).
///
/// The correct answer never leaves the server: [options] arrive already
/// shuffled by the server and the submitted choice is the 0-based index inside
/// this list, so the order must be preserved as received.
class ClaimQuestionEntity extends Equatable {
  const ClaimQuestionEntity({
    required this.id,
    required this.position,
    required this.question,
    required this.options,
  });

  /// `question_id` from `get_claim_questions`.
  final String id;

  /// 1-based order set by the finder.
  final int position;

  final String question;

  /// Shuffled multiple-choice options; index == submitted `choice`.
  final List<String> options;

  @override
  List<Object?> get props => [id, position, question, options];
}
