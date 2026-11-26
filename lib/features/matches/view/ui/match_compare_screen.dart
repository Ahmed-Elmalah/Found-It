import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/domain/entities/matches_failure.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';
import 'package:found_it/features/matches/view/widgets/comparison_field_row.dart';
import 'package:found_it/features/matches/view/widgets/match_score_badge.dart';
import 'package:found_it/features/matches/view/widgets/private_details_banner.dart';

/// Screen for detailed side-by-side comparison between your report and
/// the matched report (Figma P29 / P63).
class MatchCompareScreen extends StatefulWidget {
  final String matchId;
  final MatchEntity? match;
  final VoidCallback? onNotMyItem;
  final VoidCallback? onStartChat;
  final VoidCallback? onAnswerQuestions;

  const MatchCompareScreen({
    super.key,
    this.matchId = '',
    this.match,
    this.onNotMyItem,
    this.onStartChat,
    this.onAnswerQuestions,
  });

  String get effectiveMatchId =>
      matchId.isNotEmpty ? matchId : (match?.matchId ?? '');

  @override
  State<MatchCompareScreen> createState() => _MatchCompareScreenState();
}

class _MatchCompareScreenState extends State<MatchCompareScreen> {
  bool _isRejecting = false;

  Future<void> _handleNotMyItem(String matchId) async {
    if (widget.onNotMyItem != null) {
      widget.onNotMyItem!();
      return;
    }

    setState(() => _isRejecting = true);

    final success = await context.read<MatchesCubit>().rejectMatch(matchId);
    if (!mounted) return;
    setState(() => _isRejecting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).matchDismissedMessage),
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).matchDismissError),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleStartChat(MatchEntity match) {
    if (widget.onStartChat != null) {
      widget.onStartChat!();
      return;
    }

    context.push(AppRoutes.chatPath(match.matchId));
  }

  Future<void> _handleAnswerQuestions(MatchEntity match) async {
    if (widget.onAnswerQuestions != null) {
      widget.onAnswerQuestions!();
      return;
    }

    await context.push(AppRoutes.claimVerifyPath(match.matchId));
    if (mounted) {
      context.read<MatchesCubit>().loadDetails(match.matchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocConsumer<MatchesCubit, MatchesState>(
      listener: (context, state) {
        if (state is MatchesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapErrorMessage(state.failureType, l10n)),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        MatchEntity? match = widget.match;
        if (state is MatchDetailsLoaded &&
            (widget.effectiveMatchId.isEmpty ||
                state.match.matchId == widget.effectiveMatchId)) {
          match = state.match;
        }

        if (match == null) {
          if (state is MatchesLoading || state is MatchesInitial) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: Text(l10n.matchCompareTitle),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is MatchesError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: Text(l10n.matchCompareTitle),
              ),
              body: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48.r,
                        color: colors.error,
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        _mapErrorMessage(state.failureType, l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FilledButton.tonal(
                        onPressed: () => context
                            .read<MatchesCubit>()
                            .loadDetails(widget.effectiveMatchId),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        }

        return _buildScaffold(
          context: context,
          match: match,
          l10n: l10n,
          colors: colors,
          locale: locale,
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required MatchEntity match,
    required AppLocalizations l10n,
    required ColorScheme colors,
    required String locale,
  }) {
    final my = match.myReport;
    final other = match.otherReport;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.matchCompareTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: colors.onSurface,
          ),
        ),
        actions: [
          if (match.isAuto && match.similarity > 0)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: MatchScoreBadge(similarity: match.similarity),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Side-by-Side Summary Cards ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ReportHeaderCard(
                            headerLabel: l10n.yourReport,
                            report: my,
                            fallbackName: l10n.yourReport,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _ReportHeaderCard(
                            headerLabel: l10n.matchedReport,
                            report: other,
                            fallbackName: match.otherUserName,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // ── Private Details Security Banner ──
                    const PrivateDetailsBanner(),
                    SizedBox(height: 18.h),

                    // ── Comparison Table / Rows ──
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          ComparisonFieldRow(
                            label: l10n.categoryLabel,
                            icon: Icons.category_outlined,
                            myValue: my?.categoryName(locale) ?? '—',
                            otherValue: other?.categoryName(locale) ?? '—',
                          ),
                          const Divider(height: 1),
                          ComparisonFieldRow(
                            label: l10n.areaLabel,
                            icon: Icons.location_on_outlined,
                            myValue: my?.areaName(locale) ?? '—',
                            otherValue: other?.areaName(locale) ?? '—',
                          ),
                          const Divider(height: 1),
                          ComparisonFieldRow(
                            label: l10n.itemDateLabel,
                            icon: Icons.calendar_today_outlined,
                            myValue: my?.itemDate != null
                                ? intl.DateFormat.yMMMd().format(my!.itemDate)
                                : '—',
                            otherValue: other?.itemDate != null
                                ? intl.DateFormat.yMMMd().format(other!.itemDate)
                                : '—',
                          ),
                          if (my?.description != null ||
                              other?.description != null) ...[
                            const Divider(height: 1),
                            ComparisonFieldRow(
                              label: l10n.descriptionLabel,
                              icon: Icons.description_outlined,
                              myValue: my?.description ?? '—',
                              otherValue: other?.description ?? '—',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Actions ──
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (match.iMustAnswer)
                    AppButton(
                      label: l10n.answerVerificationQuestions,
                      onPressed: () => _handleAnswerQuestions(match),
                    )
                  else
                    AppButton(
                      label: l10n.startChat,
                      onPressed: () => _handleStartChat(match),
                    ),
                  SizedBox(height: 10.h),
                  AppButton(
                    label: l10n.notMyItem,
                    variant: AppButtonVariant.outlined,
                    isLoading: _isRejecting,
                    onPressed: () => _handleNotMyItem(match.matchId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHeaderCard extends StatelessWidget {
  final String headerLabel;
  final MatchReportSummary? report;
  final String fallbackName;

  const _ReportHeaderCard({
    required this.headerLabel,
    required this.report,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    final isLost = report?.type == 'lost';
    final typeTone = isLost ? StatusChipTone.error : StatusChipTone.success;
    final typeLabel = isLost ? l10n.typeLost : l10n.typeFound;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: double.infinity,
                  height: 100.h,
                  color: colors.surfaceContainerHighest,
                  child: report?.image != null && report!.image!.isNotEmpty
                      ? Image.network(
                          report!.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.broken_image_rounded,
                            color: colors.onSurfaceVariant,
                            size: 32.r,
                          ),
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: colors.onSurfaceVariant,
                          size: 32.r,
                        ),
                ),
              ),
              if (report != null)
                PositionedDirectional(
                  top: 6.h,
                  end: 6.w,
                  child: StatusChip(label: typeLabel, tone: typeTone),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            report?.title ?? fallbackName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

String _mapErrorMessage(MatchesFailureType type, AppLocalizations l10n) {
  return switch (type) {
    MatchesFailureType.notFound => l10n.matchesErrorNotFound,
    MatchesFailureType.notAllowed => l10n.matchesErrorNotAllowed,
    MatchesFailureType.invalidState => l10n.matchesErrorInvalidState,
    MatchesFailureType.network => l10n.matchesErrorNetwork,
    _ => l10n.matchesLoadError,
  };
}
