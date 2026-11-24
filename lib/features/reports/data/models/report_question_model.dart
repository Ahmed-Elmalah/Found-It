import 'package:found_it/features/reports/domain/entities/report_question_entity.dart';

class ReportQuestionModel extends ReportQuestionEntity {
  const ReportQuestionModel({
    required super.id,
    required super.position,
    required super.question,
    required super.correct,
    required super.wrong,
  });

  factory ReportQuestionModel.fromJson(Map<String, dynamic> json) {
    return ReportQuestionModel(
      id: json['id'] as String? ?? '',
      position: (json['position'] as num?)?.toInt() ?? 1,
      question: json['question'] as String? ?? '',
      correct: json['correct'] as String? ?? '',
      wrong: (json['wrong'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'position': position,
        'question': question,
        'correct': correct,
        'wrong': wrong,
      };
}
