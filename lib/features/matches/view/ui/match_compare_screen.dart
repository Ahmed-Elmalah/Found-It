import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';
import 'package:found_it/features/matches/domain/use_cases/reject_match_use_case.dart';
import 'package:found_it/features/matches/view/widgets/comparison_field_row.dart';
import 'package:found_it/features/matches/view/widgets/match_score_badge.dart';
import 'package:found_it/features/matches/view/widgets/private_details_banner.dart';

/// Screen for detailed side-by-side comparison between your report and
/// the matched report (Figma P29 / P63).
class MatchCompareScreen extends StatefulWidget {
  final MatchEntity match;
  final VoidCallback? onNotMyItem;
  final VoidCallback? onStartChat;

  const MatchCompareScreen({
    super.key,
    required this.match,
    this.onNotMyItem,
    this.onStartChat,
  });

  @override
  State<MatchCompareScreen> createState() => _MatchCompareScreenState();
}

class _MatchCompareScreenState extends State<MatchCompareScreen> {
  bool _isRejecting = false;

  Future<void> _handleNotMyItem() async {
    if (widget.onNotMyItem != null) {
      widget.onNotMyItem!();
      return;
    }

    setState(() => _isRejecting = true);

    try {
      await sl<RejectMatchUseCase>()(widget.match.matchId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).matchDismissedMessage),
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRejecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).matchDismissError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _handleStartChat() {
    if (widget.onStartChat != null) {
      widget.onStartChat!();
      return;
    }

    context.push(AppRoutes.messages);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final my = widget.match.myReport;
    final other = widget.match.otherReport;

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
          if (widget.match.isAuto && widget.match.similarity > 0)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16.w),
              child: MatchScoreBadge(similarity: widget.match.similarity),
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
                            fallbackName: widget.match.otherUserName,
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
                  AppButton(
                    label: l10n.startChat,
                    onPressed: _handleStartChat,
                  ),
                  SizedBox(height: 10.h),
                  AppButton(
                    label: l10n.notMyItem,
                    variant: AppButtonVariant.outlined,
                    isLoading: _isRejecting,
                    onPressed: _handleNotMyItem,
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
