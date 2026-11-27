import 'package:found_it/features/claim/domain/entities/claim_submission_result.dart';

class ClaimSubmissionModel extends ClaimSubmissionResult {
  const ClaimSubmissionModel({required super.passed, required super.matchId});

  /// Maps the `{ "passed": bool, "match_id": uuid }` RPC response.
  factory ClaimSubmissionModel.fromJson(Map<String, dynamic> json) {
    return ClaimSubmissionModel(
      passed: json['passed'] == true,
      matchId: json['match_id']?.toString() ?? '',
    );
  }
}
