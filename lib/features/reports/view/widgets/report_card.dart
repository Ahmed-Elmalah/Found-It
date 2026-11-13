import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final ReportEntity report;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final locationText = [
      report.localizedArea(locale),
      report.localizedCity(locale),
    ].where((part) => part.isNotEmpty).join(l10n.locationSeparator);

    final formattedDate = DateFormat.yMMMd(locale).format(report.itemDate);
    final metaLine = locationText.isNotEmpty
        ? '$locationText · $formattedDate'
        : formattedDate;

    final reportType = ReportType.fromDb(report.type);
    final reportStatus = ReportStatus.fromDb(report.status);

    final typeLabel =
        reportType == ReportType.lost ? l10n.typeLost : l10n.typeFound;
    final typeTone = reportType == ReportType.lost
        ? StatusChipTone.error
        : StatusChipTone.success;

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

    final hasImage = report.images.isNotEmpty;
    final isRecovered =
        report.isRecovered || reportStatus == ReportStatus.recovered;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsetsDirectional.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: thumbnail + info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        width: 86.w,
                        height: 86.w,
                        color: colors.surfaceContainerHighest,
                        child: hasImage
                            ? Image.network(
                                report.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.broken_image_outlined,
                                  color: colors.onSurfaceVariant,
                                  size: 28.r,
                                ),
                              )
                            : Icon(
                                Icons.image_outlined,
                                color: colors.onSurfaceVariant,
                                size: 28.r,
                              ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges row
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              StatusChip(label: typeLabel, tone: typeTone),
                              StatusChip(label: statusLabel, tone: statusTone),
                            ],
                          ),
                          SizedBox(height: 6.h),

                          // Title
                          Text(
                            report.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          SizedBox(height: 6.h),

                          // Meta line: "Maadi, Cairo · Nov 6"
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14.r,
                                color: colors.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  metaLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action buttons under the card
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 16.r,
                          color: colors.onSurface,
                        ),
                        label: Text(
                          l10n.edit,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 38.h),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          side: BorderSide(color: colors.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                    if (!isRecovered) ...[
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 16.r,
                            color: colors.error,
                          ),
                          label: Text(
                            l10n.deleteReport,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.error,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, 38.h),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            side: BorderSide(color: colors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
