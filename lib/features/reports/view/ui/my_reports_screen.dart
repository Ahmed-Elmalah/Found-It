import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_cubit.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';
import 'package:found_it/features/reports/view/widgets/delete_report_dialog.dart';
import 'package:found_it/features/reports/view/widgets/filter_tabs.dart';
import 'package:found_it/features/reports/view/widgets/report_card.dart';

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
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportDeletedSuccess),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

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
                child: _buildBody(context, state, colors, l10n),
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
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isFailure && state.reports.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.r,
                color: colors.error,
              ),
              SizedBox(height: 12.h),
              Text(
                state.errorMessage ?? l10n.genericErrorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: colors.onSurfaceVariant),
              ),
              SizedBox(height: 16.h),
              FilledButton.tonal(
                onPressed: () => context.read<MyReportsCubit>().refresh(),
                child: Text(l10n.genericErrorTitle),
              ),
            ],
          ),
        ),
      );
    }

    if (state.reports.isEmpty) {
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
        padding: EdgeInsetsDirectional.only(
          start: 16.w,
          end: 16.w,
          top: 4.h,
          bottom: 24.h,
        ),
        itemCount: state.reports.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return ReportCard(
            report: report,
            onEdit: () => _onEditReport(report),
            onDelete: () => _onDeleteReport(report),
          );
        },
      ),
    );
  }
}
