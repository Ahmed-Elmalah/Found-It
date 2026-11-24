import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/features/reports/domain/entities/report_question_entity.dart';

/// Draft representation of a verification question in Create/Edit report forms.
class QuestionDraft {
  String question;
  String correct;
  List<String> wrong;

  QuestionDraft({
    this.question = '',
    this.correct = '',
    List<String>? wrong,
  }) : wrong = wrong ?? ['', ''];

  Map<String, dynamic> toJson() => {
        'question': question.trim(),
        'correct': correct.trim(),
        'wrong': wrong.map((w) => w.trim()).toList(),
      };

  factory QuestionDraft.fromEntity(ReportQuestionEntity entity) {
    return QuestionDraft(
      question: entity.question,
      correct: entity.correct,
      wrong: List.from(entity.wrong),
    );
  }

  QuestionDraft copyWith({
    String? question,
    String? correct,
    List<String>? wrong,
  }) {
    return QuestionDraft(
      question: question ?? this.question,
      correct: correct ?? this.correct,
      wrong: wrong != null ? List.from(wrong) : List.from(this.wrong),
    );
  }
}

/// Interactive form widget to build 1–3 verification questions for Found reports (Story #6).
class VerificationQuestionsForm extends StatelessWidget {
  final List<QuestionDraft> questions;
  final ValueChanged<List<QuestionDraft>> onChanged;
  final String? errorText;

  const VerificationQuestionsForm({
    super.key,
    required this.questions,
    required this.onChanged,
    this.errorText,
  });

  /// Validates questions according to Story #6 backend rules:
  /// - At least 1 question for Found reports
  /// - Max 3 questions
  /// - Question 3–150 chars
  /// - Correct answer 1–80 chars
  /// - 2–3 distinct wrong answers (1–80 chars)
  /// - All answers must be distinct
  static String? validate(
    List<QuestionDraft> questions,
    AppLocalizations l10n, {
    required bool isFound,
  }) {
    if (!isFound) return null;

    if (questions.isEmpty) {
      return l10n.questionRequiredError;
    }

    for (final q in questions) {
      final qText = q.question.trim();
      if (qText.length < 3) {
        return l10n.questionTooShortError;
      }
      if (q.correct.trim().isEmpty) {
        return l10n.answerRequiredError;
      }
      if (q.wrong.length < 2) {
        return l10n.answerRequiredError;
      }
      for (final w in q.wrong) {
        if (w.trim().isEmpty) {
          return l10n.answerRequiredError;
        }
      }

      // Check duplicates (case-insensitive)
      final allAnswers = [
        q.correct.trim().toLowerCase(),
        ...q.wrong.map((w) => w.trim().toLowerCase()),
      ];
      if (allAnswers.toSet().length != allAnswers.length) {
        return l10n.duplicateAnswersError;
      }
    }

    return null;
  }

  void _addQuestion() {
    if (questions.length >= 3) return;
    final updated = List<QuestionDraft>.from(questions)..add(QuestionDraft());
    onChanged(updated);
  }

  void _removeQuestion(int index) {
    final updated = List<QuestionDraft>.from(questions)..removeAt(index);
    onChanged(updated);
  }

  void _updateQuestionText(int index, String text) {
    final updated = List<QuestionDraft>.from(questions);
    updated[index].question = text;
    onChanged(updated);
  }

  void _updateCorrect(int index, String text) {
    final updated = List<QuestionDraft>.from(questions);
    updated[index].correct = text;
    onChanged(updated);
  }

  void _updateWrong(int qIndex, int wIndex, String text) {
    final updated = List<QuestionDraft>.from(questions);
    updated[qIndex].wrong[wIndex] = text;
    onChanged(updated);
  }

  void _addWrongChoice(int qIndex) {
    final updated = List<QuestionDraft>.from(questions);
    if (updated[qIndex].wrong.length < 3) {
      updated[qIndex].wrong.add('');
      onChanged(updated);
    }
  }

  void _removeWrongChoice(int qIndex, int wIndex) {
    final updated = List<QuestionDraft>.from(questions);
    if (updated[qIndex].wrong.length > 2) {
      updated[qIndex].wrong.removeAt(wIndex);
      onChanged(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_outlined,
                size: 18.r,
                color: colors.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.verificationQuestionsTitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10n.verificationQuestionsSubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (errorText != null) ...[
          SizedBox(height: 8.h),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        SizedBox(height: 12.h),

        // Questions List
        for (int i = 0; i < questions.length; i++) ...[
          _QuestionCard(
            index: i,
            draft: questions[i],
            canDelete: questions.length > 1,
            onDelete: () => _removeQuestion(i),
            onQuestionChanged: (val) => _updateQuestionText(i, val),
            onCorrectChanged: (val) => _updateCorrect(i, val),
            onWrongChanged: (wIndex, val) => _updateWrong(i, wIndex, val),
            onAddWrong: () => _addWrongChoice(i),
            onRemoveWrong: (wIndex) => _removeWrongChoice(i, wIndex),
          ),
          SizedBox(height: 12.h),
        ],

        // Add Question Button
        if (questions.length < 3)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l10n.addQuestionButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int index;
  final QuestionDraft draft;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<String> onQuestionChanged;
  final ValueChanged<String> onCorrectChanged;
  final void Function(int wIndex, String val) onWrongChanged;
  final VoidCallback onAddWrong;
  final ValueChanged<int> onRemoveWrong;

  const _QuestionCard({
    required this.index,
    required this.draft,
    required this.canDelete,
    required this.onDelete,
    required this.onQuestionChanged,
    required this.onCorrectChanged,
    required this.onWrongChanged,
    required this.onAddWrong,
    required this.onRemoveWrong,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late final TextEditingController _qController;
  late final TextEditingController _correctController;
  late final List<TextEditingController> _wrongControllers;

  @override
  void initState() {
    super.initState();
    _qController = TextEditingController(text: widget.draft.question);
    _correctController = TextEditingController(text: widget.draft.correct);
    _wrongControllers = widget.draft.wrong
        .map((w) => TextEditingController(text: w))
        .toList();
  }

  @override
  void didUpdateWidget(covariant _QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft != widget.draft) {
      if (_qController.text != widget.draft.question) {
        _qController.text = widget.draft.question;
      }
      if (_correctController.text != widget.draft.correct) {
        _correctController.text = widget.draft.correct;
      }
      while (_wrongControllers.length < widget.draft.wrong.length) {
        _wrongControllers.add(TextEditingController(
            text: widget.draft.wrong[_wrongControllers.length]));
      }
      while (_wrongControllers.length > widget.draft.wrong.length) {
        _wrongControllers.removeLast().dispose();
      }
      for (int i = 0; i < widget.draft.wrong.length; i++) {
        if (_wrongControllers[i].text != widget.draft.wrong[i]) {
          _wrongControllers[i].text = widget.draft.wrong[i];
        }
      }
    }
  }

  @override
  void dispose() {
    _qController.dispose();
    _correctController.dispose();
    for (final c in _wrongControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question # + Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.questionNumber(widget.index + 1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              if (widget.canDelete)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 20.r, color: colors.error),
                  tooltip: l10n.removeQuestionButton,
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SizedBox(height: 8.h),

          // Question Text
          AppTextField(
            controller: _qController,
            label: l10n.questionTextLabel,
            hint: l10n.questionTextHint,
            maxLength: 150,
            onChanged: widget.onQuestionChanged,
          ),
          SizedBox(height: 12.h),

          // Correct Answer
          AppTextField(
            controller: _correctController,
            label: l10n.correctAnswerLabel,
            hint: l10n.correctAnswerHint,
            maxLength: 80,
            prefixIcon: Icons.check_circle_rounded,
            onChanged: widget.onCorrectChanged,
          ),
          SizedBox(height: 12.h),

          // Wrong choices
          for (int w = 0; w < widget.draft.wrong.length; w++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    controller: w < _wrongControllers.length
                        ? _wrongControllers[w]
                        : null,
                    label: l10n.wrongChoiceLabel(w + 1),
                    hint: l10n.wrongChoiceHint,
                    maxLength: 80,
                    prefixIcon: Icons.cancel_rounded,
                    onChanged: (val) => widget.onWrongChanged(w, val),
                  ),
                ),
                if (widget.draft.wrong.length > 2)
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18.r, color: colors.error),
                    onPressed: () => widget.onRemoveWrong(w),
                    padding: EdgeInsets.only(top: 14.h),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
          ],

          if (widget.draft.wrong.length < 3)
            TextButton.icon(
              onPressed: widget.onAddWrong,
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                l10n.addWrongChoiceButton,
                style: TextStyle(fontSize: 12.5.sp),
              ),
            ),
        ],
      ),
    );
  }
}
