import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/theme/app_colors.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/features/claim/view/cubit/claim_cubit.dart';
import 'package:found_it/features/claim/view/cubit/claim_state.dart';
import 'package:found_it/features/claim/view/widgets/claim_confirm_dialog.dart';
import 'package:found_it/features/claim/view/widgets/claim_question_card.dart';

/// Verify Ownership (Story #6) — `/matches/:id/verify`.
///
/// The claimant answers all of the finder's questions, confirms the one-chance
/// warning, and either lands in the chat (passed) or on the blocked screen
/// (failed). Load and submit errors are retryable and keep the selections.
class VerifyOwnershipScreen extends StatefulWidget {
  const VerifyOwnershipScreen({super.key, required this.matchId});

  final String matchId;

  @override
  State<VerifyOwnershipScreen> createState() => _VerifyOwnershipScreenState();
}

class _VerifyOwnershipScreenState extends State<VerifyOwnershipScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<ClaimCubit>();
    if (cubit.state.status == ClaimStatus.initial) {
      unawaited(cubit.loadQuestions(widget.matchId));
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.matches);
    }
  }

  Future<void> _confirmAndSubmit() async {
    final cubit = context.read<ClaimCubit>();
    if (!cubit.state.canSubmit) return;

    final confirmed = await ClaimConfirmDialog.show(context);
    if (confirmed == true && mounted) {
      await cubit.submitAnswers();
    }
  }

  void _goToChat(ClaimState state) {
    final matchId = state.passedMatchId ?? widget.matchId;
    // `go` replaces the stack: back must not return to the one-chance form.
    context.go(AppRoutes.chatPath(matchId));
  }

  void _goToMatches() {
    context.go(AppRoutes.matches);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ClaimCubit, ClaimState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ClaimStatus.passed) {
          _goToChat(state);
        }
      },
      builder: (context, state) {
        final cubit = context.read<ClaimCubit>();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _ClaimHeader(onBack: _handleBack),
                Expanded(
                  child: switch (state.status) {
                    ClaimStatus.initial ||
                    ClaimStatus.loading => const _ClaimLoadingView(),
                    ClaimStatus.loadFailure => _ClaimLoadErrorView(
                      key: const ValueKey('claim_load_error'),
                      onRetry: () => cubit.loadQuestions(widget.matchId),
                    ),
                    ClaimStatus.failed => _ClaimFailedView(
                      key: const ValueKey('claim_failed'),
                      onBackToMatches: _goToMatches,
                    ),
                    ClaimStatus.ready ||
                    ClaimStatus.submitting ||
                    ClaimStatus.submitFailure => _ClaimQuestionsList(
                      state: state,
                    ),
                    // The listener is already navigating to the chat.
                    ClaimStatus.passed => const _ClaimLoadingView(),
                  },
                ),
                if (state.status == ClaimStatus.ready ||
                    state.status == ClaimStatus.submitting ||
                    state.status == ClaimStatus.submitFailure)
                  _ClaimSubmitArea(state: state, onSubmit: _confirmAndSubmit),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClaimHeader extends StatelessWidget {
  const _ClaimHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          InkWell(
            key: const ValueKey('claim_back'),
            onTap: () {
              HapticFeedback.lightImpact();
              onBack();
            },
            borderRadius: BorderRadius.circular(22.r),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 21.r,
                color: colors.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.claimVerifyTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.claimVerifySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimQuestionsList extends StatelessWidget {
  const _ClaimQuestionsList({required this.state});

  final ClaimState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubit = context.read<ClaimCubit>();

    return ListView(
      key: const ValueKey('claim_questions_list'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.successDark : AppColors.successLight)
                .withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18.r,
                color: isDark ? AppColors.successDark : AppColors.successLight,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10n.claimVerifyNotice,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.status == ClaimStatus.submitFailure) ...[
          SizedBox(height: 12.h),
          Container(
            key: const ValueKey('claim_submit_error'),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, size: 18.r, color: colors.error),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    l10n.claimSubmitError,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        for (var index = 0; index < state.questions.length; index++) ...[
          SizedBox(height: 12.h),
          ClaimQuestionCard(
            index: index,
            question: state.questions[index],
            selectedChoice: state.choiceFor(state.questions[index].id),
            onSelected: (choice) =>
                cubit.selectAnswer(state.questions[index].id, choice),
          ),
        ],
      ],
    );
  }
}

class _ClaimSubmitArea extends StatelessWidget {
  const _ClaimSubmitArea({required this.state, required this.onSubmit});

  final ClaimState state;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: colors.outline.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!state.allAnswered) ...[
            Text(
              l10n.claimAnswerAllHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: colors.onSurfaceVariant),
            ),
            SizedBox(height: 8.h),
          ],
          AppButton(
            key: const ValueKey('claim_submit'),
            label: l10n.claimSubmitAnswers,
            isLoading: state.isSubmitting,
            onPressed: state.canSubmit ? onSubmit : null,
          ),
        ],
      ),
    );
  }
}

class _ClaimLoadingView extends StatelessWidget {
  const _ClaimLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('claim_loading'),
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _ClaimLoadErrorView extends StatelessWidget {
  const _ClaimLoadErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56.r, color: colors.error),
            SizedBox(height: 16.h),
            Text(
              l10n.claimLoadErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.claimLoadErrorSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              key: const ValueKey('claim_retry'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimFailedView extends StatelessWidget {
  const _ClaimFailedView({super.key, required this.onBackToMatches});

  final VoidCallback onBackToMatches;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.r,
              height: 76.r,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block_rounded, size: 40.r, color: colors.error),
            ),
            SizedBox(height: 18.h),
            Text(
              l10n.claimBlocked,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.claimFailedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('claim_back_to_matches'),
                onPressed: onBackToMatches,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  l10n.claimBackToMatches,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
