import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:found_it/core/di/injection.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/view/cubit/matches_cubit.dart';
import 'package:found_it/features/matches/view/cubit/matches_state.dart';
import 'package:found_it/features/matches/view/widgets/potential_matches_section.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/recovery/view/widgets/mark_recovered_button.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';
import 'package:found_it/features/reports/view/cubit/report_details_cubit.dart';
import 'package:found_it/features/reports/view/cubit/report_details_state.dart';
import 'package:found_it/features/reports/view/widgets/report_image_gallery.dart';

class ReportDetailsScreen extends StatelessWidget {
  final String reportId;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ReportDetailsCubit>()..loadReport(reportId),
        ),
        BlocProvider(
          create: (_) => sl<MatchesCubit>()..loadMatches(reportId: reportId),
        ),
      ],
      child: const _ReportDetailsView(),
    );
  }
}

class _ReportDetailsView extends StatelessWidget {
  const _ReportDetailsView();

  void _onClaimStateChanged(BuildContext context, ReportDetailsState state) {
    final l10n = AppLocalizations.of(context);

    if (state.claimStatus == ClaimStatus.success && state.claimResult != null) {
      final result = state.claimResult!;
      context.read<ReportDetailsCubit>().resetClaimStatus();

      if (result.isClaimPending) {
        context.push(AppRoutes.claimVerifyPath(result.matchId));
      } else {
        context.push(AppRoutes.chatPath(result.matchId));
      }
    } else if (state.claimStatus == ClaimStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.claimFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<ReportDetailsCubit, ReportDetailsState>(
      listenWhen: (prev, curr) => prev.claimStatus != curr.claimStatus,
      listener: _onClaimStateChanged,
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.reportDetailsTitle),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.isNotFound) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.reportDetailsTitle),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64.r,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.reportNotFoundTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.reportNotFoundMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    AppButton(
                      label: l10n.cancel,
                      variant: AppButtonVariant.outlined,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.isFailure || state.report == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.reportDetailsTitle),
            ),
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64.r,
                      color: colors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.chatErrorUnknown,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    AppButton(
                      label: l10n.retry,
                      onPressed: () => context.read<ReportDetailsCubit>().refresh(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final report = state.report!;
        return _ReportDetailsContent(report: report, state: state);
      },
    );
  }
}

class _ReportDetailsContent extends StatelessWidget {
  final ReportDetailsEntity report;
  final ReportDetailsState state;

  const _ReportDetailsContent({
    required this.report,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final reportType = ReportType.fromDb(report.type);
    final reportStatus = ReportStatus.fromDb(report.status);

    final typeLabel = reportType == ReportType.lost ? l10n.typeLost : l10n.typeFound;
    final typeTone = reportType == ReportType.lost ? StatusChipTone.error : StatusChipTone.success;

    final statusLabel = switch (reportStatus) {
      ReportStatus.active => l10n.statusActive,
      ReportStatus.matching => l10n.statusMatching,
      ReportStatus.recovered => l10n.statusRecovered,
    };
    final statusTone = switch (reportStatus) {
      ReportStatus.active => StatusChipTone.primary,
      ReportStatus.matching => StatusChipTone.primary,
      ReportStatus.recovered => StatusChipTone.success,
    };

    final formattedDate = DateFormat.yMMMMd(locale).format(report.itemDate);
    final locationText = [
      report.localizedArea(locale),
      report.localizedCity(locale),
    ].where((s) => s.isNotEmpty).join(l10n.locationSeparator);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportDetailsTitle),
        actions: [
          if (report.isMine && !report.isRecovered)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.editReportTitle,
              onPressed: () async {
                final edited = await context.push<bool>(
                  AppRoutes.editReport,
                  extra: report.toReportEntity(),
                );
                if (context.mounted && edited == true) {
                  context.read<ReportDetailsCubit>().refresh();
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Swipeable Image Gallery
            ReportImageGallery(
              images: report.images,
              heroTagPrefix: 'report_${report.id}',
            ),
            SizedBox(height: 16.h),

            // 2. Badges Row: Lost/Found + Status + #RPT- ID
            Row(
              children: [
                StatusChip(label: typeLabel, tone: typeTone),
                SizedBox(width: 8.w),
                StatusChip(label: statusLabel, tone: statusTone),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: report.refCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${report.refCode} copied'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          report.refCode,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.copy_rounded,
                          size: 13.r,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 3. Title
            Text(
              report.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
                height: 1.3,
              ),
            ),
            SizedBox(height: 16.h),

            // 4. Meta Details Card (Category, Location, Date)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  _MetaRow(
                    icon: Icons.category_outlined,
                    label: l10n.reportDetailsCategory,
                    value: report.localizedCategory(locale),
                  ),
                  Divider(height: 16.h, thickness: 0.8, color: colors.outlineVariant.withValues(alpha: 0.3)),
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    label: l10n.reportDetailsLocation,
                    value: locationText,
                  ),
                  Divider(height: 16.h, thickness: 0.8, color: colors.outlineVariant.withValues(alpha: 0.3)),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.reportDetailsDate,
                    value: formattedDate,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 5. Description Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportDetailsDescription,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    report.description?.isNotEmpty == true ? report.description! : '—',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 6. Private Details Section
            if (report.isMine) ...[
              if (report.privateDetails != null && report.privateDetails!.isNotEmpty)
                _PrivateDetailsCard(
                  title: l10n.reportDetailsPrivateDetails,
                  content: report.privateDetails!,
                  helperText: l10n.privateDetailsOwnerNotice,
                  isOwner: true,
                ),
            ] else ...[
              if (report.hasPrivateDetails)
                _PrivateDetailsCard(
                  title: l10n.reportDetailsPrivateDetails,
                  content: l10n.privateDetailsHiddenNotice,
                  helperText: null,
                  isOwner: false,
                ),
              if (report.hasQuestions) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.quiz_outlined, size: 20.r, color: colors.primary),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10n.questionsNotice,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // 7. Owner Sections (Edit Report, Mark Recovered & Potential Matches)
            if (report.isMine) ...[
              SizedBox(height: 20.h),
              if (!report.isRecovered) ...[
                AppButton(
                  label: l10n.editReportTitle,
                  variant: AppButtonVariant.outlined,
                  onPressed: () async {
                    final edited = await context.push<bool>(
                      AppRoutes.editReport,
                      extra: report.toReportEntity(),
                    );
                    if (context.mounted && edited == true) {
                      context.read<ReportDetailsCubit>().refresh();
                    }
                  },
                ),
                SizedBox(height: 12.h),
              ],
              BlocBuilder<MatchesCubit, MatchesState>(
                builder: (context, matchesState) {
                  final matches = matchesState is MatchesLoaded
                      ? matchesState.matches
                      : const <MatchEntity>[];
                  final recoveryMatchId = report.myMatchId ??
                      (matches.isNotEmpty ? matches.first.matchId : null);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!report.isRecovered && recoveryMatchId != null) ...[
                        MarkRecoveredButton(
                          onConfirmed: () async {
                            final recoveryCubit = sl<RecoveryCubit>();
                            final ok = await recoveryCubit.confirmRecovery(recoveryMatchId);
                            if (ok && context.mounted) {
                              context.read<ReportDetailsCubit>().refresh();
                            }
                          },
                        ),
                        SizedBox(height: 16.h),
                      ],
                      PotentialMatchesSection(
                        matches: matches,
                        onViewAll: () {
                          context.push('${AppRoutes.matches}?reportId=${report.id}');
                        },
                        onSelectMatch: (MatchEntity match) {
                          context.push(AppRoutes.matchComparePath(match.matchId), extra: match);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],

            SizedBox(height: 90.h),
          ],
        ),
      ),
      bottomNavigationBar: !report.isMine
          ? _NonOwnerBottomBar(report: report, state: state)
          : null,
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18.r, color: colors.primary),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivateDetailsCard extends StatelessWidget {
  final String title;
  final String content;
  final String? helperText;
  final bool isOwner;

  const _PrivateDetailsCard({
    required this.title,
    required this.content,
    required this.helperText,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isOwner
            ? colors.surfaceContainerHighest.withValues(alpha: 0.4)
            : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isOwner
              ? colors.primary.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOwner ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                size: 18.r,
                color: isOwner ? colors.primary : colors.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isOwner ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              fontStyle: isOwner ? FontStyle.normal : FontStyle.italic,
              color: isOwner ? colors.onSurface : colors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          if (helperText != null) ...[
            SizedBox(height: 6.h),
            Text(
              helperText!,
              style: TextStyle(
                fontSize: 11.sp,
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NonOwnerBottomBar extends StatelessWidget {
  final ReportDetailsEntity report;
  final ReportDetailsState state;

  const _NonOwnerBottomBar({
    required this.report,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    Widget button;
    if (report.iAmBlocked) {
      button = AppButton(
        label: l10n.claimBlocked,
        onPressed: null,
      );
    } else if (report.hasActiveMatchWithMe) {
      button = AppButton(
        label: l10n.openChat,
        onPressed: () {
          context.push(AppRoutes.chatPath(report.myMatchId!));
        },
      );
    } else {
      final buttonLabel = report.isLost ? l10n.iFoundThis : l10n.thisIsMine;
      button = AppButton(
        label: buttonLabel,
        isLoading: state.isClaimLoading,
        onPressed: () {
          context.read<ReportDetailsCubit>().claimReport();
        },
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: button,
    );
  }
}
