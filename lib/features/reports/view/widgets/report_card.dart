import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/view/widgets/report_type_badge.dart';
import 'package:found_it/features/reports/view/widgets/status_badge.dart';

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
    ].where((part) => part.isNotEmpty).join('، ');

    final formattedDate = DateFormat.yMMMd(locale).format(report.itemDate);
    final hasImage = report.images.isNotEmpty;

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
            child: Row(
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
                      // Badges row + Popup menu
                      Row(
                        children: [
                          ReportTypeBadge(type: report.type),
                          SizedBox(width: 6.w),
                          StatusBadge(status: report.status),
                          const Spacer(),
                          SizedBox(
                            width: 24.r,
                            height: 24.r,
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20.r,
                                color: colors.onSurfaceVariant,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') onEdit?.call();
                                if (value == 'delete') onDelete?.call();
                              },
                              itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18.r,
                                      color: colors.onSurface,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      l10n.edit,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18.r,
                                      color: colors.error,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      l10n.delete,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: colors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                      SizedBox(height: 4.h),

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

                      // Location & Date
                      if (locationText.isNotEmpty)
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
                                locationText,
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
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13.r,
                            color: colors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
