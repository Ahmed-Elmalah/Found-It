import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/domain/entities/report_question_entity.dart';
import 'package:found_it/features/reports/view/ui/widgets/verification_questions_form.dart';
import '../../../../../helpers/test_app.dart';

void main() {
  group('QuestionDraft Tests', () {
    test('toJson returns trimmed map with question, correct, and wrong', () {
      final draft = QuestionDraft(
        question: ' What color? ',
        correct: ' Black ',
        wrong: [' Brown ', ' Blue '],
      );

      final json = draft.toJson();

      expect(json['question'], 'What color?');
      expect(json['correct'], 'Black');
      expect(json['wrong'], ['Brown', 'Blue']);
    });

    test('fromEntity populates QuestionDraft from ReportQuestionEntity', () {
      const entity = ReportQuestionEntity(
        id: 'q1',
        position: 1,
        question: 'Brand?',
        correct: 'Apple',
        wrong: ['Samsung', 'Huawei'],
      );

      final draft = QuestionDraft.fromEntity(entity);

      expect(draft.question, 'Brand?');
      expect(draft.correct, 'Apple');
      expect(draft.wrong, ['Samsung', 'Huawei']);
    });
  });

  group('VerificationQuestionsForm Validation Tests', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('returns null when report is not found even if questions empty', () {
      final error = VerificationQuestionsForm.validate([], l10n, isFound: false);
      expect(error, isNull);
    });

    test('returns error when questions list is empty for found report', () {
      final error = VerificationQuestionsForm.validate([], l10n, isFound: true);
      expect(error, l10n.questionRequiredError);
    });

    test('returns error when question text is shorter than 3 characters', () {
      final questions = [
        QuestionDraft(question: 'No', correct: 'Yes', wrong: ['A', 'B']),
      ];
      final error = VerificationQuestionsForm.validate(questions, l10n, isFound: true);
      expect(error, l10n.questionTooShortError);
    });

    test('returns error when correct answer is empty', () {
      final questions = [
        QuestionDraft(question: 'Valid Question?', correct: '', wrong: ['A', 'B']),
      ];
      final error = VerificationQuestionsForm.validate(questions, l10n, isFound: true);
      expect(error, l10n.answerRequiredError);
    });

    test('returns error when any wrong answer is empty', () {
      final questions = [
        QuestionDraft(question: 'Valid Question?', correct: 'Right', wrong: ['Wrong 1', '']),
      ];
      final error = VerificationQuestionsForm.validate(questions, l10n, isFound: true);
      expect(error, l10n.answerRequiredError);
    });

    test('returns error when answers have duplicates (case-insensitive)', () {
      final questions = [
        QuestionDraft(
          question: 'Valid Question?',
          correct: 'Black',
          wrong: ['black', 'Blue'],
        ),
      ];
      final error = VerificationQuestionsForm.validate(questions, l10n, isFound: true);
      expect(error, l10n.duplicateAnswersError);
    });

    test('returns null when all fields are valid and distinct', () {
      final questions = [
        QuestionDraft(
          question: 'What color is the wallet?',
          correct: 'Black',
          wrong: ['Brown', 'Blue'],
        ),
      ];
      final error = VerificationQuestionsForm.validate(questions, l10n, isFound: true);
      expect(error, isNull);
    });
  });

  group('VerificationQuestionsForm Widget Tests', () {
    testWidgets('renders questions form, fields, and handles add/delete', (tester) async {
      List<QuestionDraft> currentQuestions = [
        QuestionDraft(
          question: 'Color?',
          correct: 'Black',
          wrong: ['Brown', 'Blue'],
        ),
      ];

      await pumpTestApp(
        tester,
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: VerificationQuestionsForm(
                  questions: currentQuestions,
                  onChanged: (updated) {
                    setState(() {
                      currentQuestions = updated;
                    });
                  },
                ),
              );
            },
          ),
        ),
        padded: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Ownership Verification Questions'), findsOneWidget);
      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('+ Add Question'), findsOneWidget);

      // Tap + Add Question
      await tester.tap(find.text('+ Add Question'));
      await tester.pumpAndSettle();

      expect(find.text('Question 2'), findsOneWidget);
      expect(currentQuestions.length, 2);

      // Now Delete button exists because questions.length > 1
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsNWidgets(2));

      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(currentQuestions.length, 1);
      expect(find.text('Question 2'), findsNothing);
    });
  });
}
