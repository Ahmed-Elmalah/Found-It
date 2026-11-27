import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/claim/domain/entities/claim_question_entity.dart';

/// One question with its multiple-choice option cards (Section 10).
///
/// The server shuffles [ClaimQuestionEntity.options], so the cards are rendered
/// in the received order: the tapped index is the `choice` sent back.
class ClaimQuestionCard extends StatelessWidget {
  const ClaimQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.selectedChoice,
    required this.onSelected,
  });

  /// 0-based index in the screen list (displayed as 1-based).
  final int index;

  final ClaimQuestionEntity question;

  /// Currently selected option index, or null.
  final int? selectedChoice;

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      key: ValueKey('claim_question_${question.id}'),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHighest : colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.questionNumber(index + 1),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colors.primary,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            question.question,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),
          for (
            var optionIndex = 0;
            optionIndex < question.options.length;
            optionIndex++
          ) ...[
            _ClaimOptionCard(
              key: ValueKey('claim_option_${question.id}_$optionIndex'),
              label: question.options[optionIndex],
              selected: selectedChoice == optionIndex,
              onTap: () => onSelected(optionIndex),
            ),
            if (optionIndex != question.options.length - 1)
              SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _ClaimOptionCard extends StatelessWidget {
  const _ClaimOptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withValues(alpha: isDark ? 0.20 : 0.08)
                : (isDark ? colors.surface : colors.surfaceContainerHighest)
                      .withValues(alpha: isDark ? 1 : 0.45),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.onSurfaceVariant,
                    width: selected ? 2 : 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
