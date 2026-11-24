import 'package:found_it/features/reports/domain/entities/manual_match_result_entity.dart';

class ManualMatchResultModel extends ManualMatchResultEntity {
  const ManualMatchResultModel({
    required super.matchId,
    required super.status,
    required super.claimStatus,
    required super.isNew,
  });

  factory ManualMatchResultModel.fromJson(Map<String, dynamic> json) {
    return ManualMatchResultModel(
      matchId: json['match_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'potential',
      claimStatus: json['claim_status'] as String? ?? 'not_required',
      isNew: json['is_new'] as bool? ?? true,
    );
  }
}
