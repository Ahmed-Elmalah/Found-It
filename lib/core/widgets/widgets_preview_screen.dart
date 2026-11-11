import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/report_card.dart';
import 'package:found_it/core/widgets/report_status.dart';
import 'package:found_it/core/widgets/status_chip.dart';

/// TEMPORARY preview screen (Task #1 of User Story #2).
///
/// Renders [StatusChip] and [ReportCard] in both light and dark themes so
/// the design can be signed off before the real screens exist. Screen-only
/// labels here are intentionally not localized - the whole file is deleted
/// (together with its route) once the Home / Explore screens use these
/// widgets with real data.
class WidgetsPreviewScreen extends StatelessWidget {
  const WidgetsPreviewScreen({super.key});

  static final List<_ReportPreviewData> _mockReports = [
    _ReportPreviewData(
      title: 'Black leather wallet with a metal clasp',
      status: ReportStatus.lost,
      location: 'Nasr City, Cairo',
      date: DateTime(2026, 10, 28),
      imageUrl: 'https://picsum.photos/seed/found-it-wallet/200',
    ),
    _ReportPreviewData(
      title: 'Student ID card',
      status: ReportStatus.found,
      location: 'Dokki, Giza',
      date: DateTime(2026, 11, 2),
      imageUrl: 'https://picsum.photos/seed/found-it-id/200',
    ),
    _ReportPreviewData(
      title: 'AirPods Pro case covered in space stickers',
      status: ReportStatus.active,
      location: 'Smouha, Alexandria',
      date: DateTime(2026, 11, 8),
      // No image -> shows the themed placeholder.
      imageUrl: null,
    ),
    _ReportPreviewData(
      title: 'Golden ring',
      status: ReportStatus.resolved,
      location: 'Zamalek, Cairo',
      date: DateTime(2026, 9, 15),
      imageUrl: 'https://picsum.photos/seed/found-it-ring/200',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Preview')),
      body: ListView(
        padding: EdgeInsets.all(AppSizes.pagePadding.w),
        children: [
          _section(
            title: 'StatusChip - Light',
            theme: AppTheme.light,
            builder: _buildChips,
          ),
          _section(
            title: 'StatusChip - Dark',
            theme: AppTheme.dark,
            builder: _buildChips,
          ),
          _section(
            title: 'ReportCard - Light',
            theme: AppTheme.light,
            builder: _buildReportCards,
          ),
          _section(
            title: 'ReportCard - Dark',
            theme: AppTheme.dark,
            builder: _buildReportCards,
          ),
        ],
      ),
    );
  }

  /// A themed box with a title. [builder] runs inside [Theme], so everything
  /// it builds resolves light or dark colors through `Theme.of(context)`.
  Widget _section({
    required String title,
    required ThemeData theme,
    required WidgetBuilder builder,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Theme(
        data: theme,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.pagePadding.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radius.r),
            border: Border.fromBorderSide(
              BorderSide(color: theme.colorScheme.outline),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Builder(builder: builder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final status in ReportStatus.values)
          StatusChip(text: status.label(l10n), color: status.color(context)),
      ],
    );
  }

  Widget _buildReportCards(BuildContext context) {
    return Column(
      children: [
        for (final report in _mockReports)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ReportCard(
              title: report.title,
              status: report.status,
              location: report.location,
              date: report.date,
              imageUrl: report.imageUrl,
              onTap: () => _showTapped(context, report.title),
            ),
          ),
      ],
    );
  }

  void _showTapped(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Tapped: $title')));
  }
}

/// Mock data for this preview only. Replaced by the real report model once
/// the `reports` feature lands.
class _ReportPreviewData {
  const _ReportPreviewData({
    required this.title,
    required this.status,
    required this.location,
    required this.date,
    required this.imageUrl,
  });

  final String title;
  final ReportStatus status;
  final String location;
  final DateTime date;
  final String? imageUrl;
}
