import 'package:equatable/equatable.dart';

class ReportQuestionEntity extends Equatable {
  final String id;
  final int position;
  final String question;
  final String correct;
  final List<String> wrong;

  const ReportQuestionEntity({
    required this.id,
    required this.position,
    required this.question,
    required this.correct,
    required this.wrong,
  });

  @override
  List<Object?> get props => [id, position, question, correct, wrong];
}
