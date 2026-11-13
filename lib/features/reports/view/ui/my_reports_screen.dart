import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';
import 'package:found_it/features/reports/view/widgets/delete_report_dialog.dart';
import 'package:found_it/features/reports/view/widgets/filter_tabs.dart';
import 'package:found_it/features/reports/view/widgets/my_report_card.dart';

/// My Reports screen (Figma P21 Light / P54 Dark).
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyReportsCubit>().loadReports();
  }

  void _onEditReport(ReportEntity report) async {
    final result = await context.push<bool>(
      AppRoutes.editReport,
      extra: report,
    );
    if (result == true && mounted) {
      context.read<MyReportsCubit>().refresh();
    }
  }

  void _onDeleteReport(ReportEntity report) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MyReportsCubit>();

    DeleteReportDialog.show(
      context,
      onConfirm: () async {
        Navigator.of(context).pop();
        final success = await cubit.deleteReport(report.id);
        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportDeletedSuccess),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          final failureType = cubit.state.failure ?? ReportFailureType.unknown;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mapFailureMessage(failureType, l10n)),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  static String _mapFailureTitle(ReportFailureType type, AppLocalizations l10n) {
    switch (type) {
      case ReportFailureType.network:
        return l10n.connectionErrorTitle;
      case ReportFailureType.notLoggedIn:
        return l10n.notLoggedInTitle;
      case ReportFailureType.invalidData:
        return l10n.invalidDataTitle;
      case ReportFailureType.unknown:
        return l10n.genericErrorTitle;
    }
  }

  static String _mapFailureMessage(ReportFailureType type, AppLocalizations l10n) {
    switch (type) {
      case ReportFailureType.network:
        return l10n.connectionErrorMessage;
      case ReportFailureType.notLoggedIn:
        return l10n.notLoggedInMessage;
      case ReportFailureType.invalidData:
        return l10n.invalidDataMessage;
      case ReportFailureType.unknown:
        return l10n.genericErrorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myReportsTitle,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<MyReportsCubit, MyReportsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              FilterTabs(
                selectedFilter: state.selectedFilter,
                counts: state.counts,
                onFilterSelected: (filter) {
                  context.read<MyReportsCubit>().setFilter(filter);
                },
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _buildBody(context, state, l10n),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MyReportsState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isFailure && state.reports.isEmpty) {
      final failureType = state.failure ?? ReportFailureType.unknown;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ErrorBanner(
                title: _mapFailureTitle(failureType, l10n),
                message: _mapFailureMessage(failureType, l10n),
              ),
              SizedBox(height: 16.h),
              FilledButton.tonal(
                onPressed: () => context.read<MyReportsCubit>().refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reports.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 40.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.noReportsTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.noReportsSubtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MyReportsCubit>().refresh(),
      child: ListView.separated(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 4.h, 16.w, 24.h),
        itemCount: state.reports.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return MyReportCard(
            report: report,
            onEdit: () => _onEditReport(report),
            onDelete: () => _onDeleteReport(report),
          );
        },
      ),
    );
  }
}
