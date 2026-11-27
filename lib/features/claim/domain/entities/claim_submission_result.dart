import 'package:equatable/equatable.dart';

/// Result of `submit_claim_answers`.
///
/// `passed == false` means the match is now rejected and the user is blocked
/// from the report. The server never says which answer was wrong.
class ClaimSubmissionResult extends Equatable {
  const ClaimSubmissionResult({required this.passed, required this.matchId});

  final bool passed;

  /// Match to open in chat when [passed] is true.
  final String matchId;

  @override
  List<Object?> get props => [passed, matchId];
}
