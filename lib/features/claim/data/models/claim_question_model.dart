import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';

class ClaimQuestionModel extends ClaimQuestionEntity {
  const ClaimQuestionModel({
    required super.id,
    required super.position,
    required super.question,
    required super.options,
  });

  /// Maps one element of the `get_claim_questions` JSON array.
  factory ClaimQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];

    return ClaimQuestionModel(
      id: json['question_id']?.toString() ?? '',
      position: (json['position'] as num?)?.toInt() ?? 0,
      question: json['question']?.toString() ?? '',
      options: rawOptions is List
          ? rawOptions
                .map((option) => option.toString())
                .toList(growable: false)
          : const [],
    );
  }
}
