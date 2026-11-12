import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/status_chip.dart';

/// Horizontal report card used by the feeds (Figma P19 / P52).
///
/// Thumbnail on the start edge (rounded, with a placeholder when the image is
/// missing), title, the report type chip, an optional status chip for
/// non-active reports, and a meta line with the location and item date.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    required this.type,
    required this.status,
    required this.location,
    required this.date,
    this.imageUrl,
    this.onTap,
  });

  /// Item title, e.g. "AirPods Pro, white case".
  final String title;

  /// Lost / found - drives the first chip.
  final ReportType type;

  /// Report status - a chip is added only when it is not active.
  final ReportStatus status;

  /// Already localized location, e.g. "Zamalek, Cairo".
  final String location;

  /// The day the item was lost / found.
  final DateTime date;

  /// First photo of the report, if any.
  final String? imageUrl;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    final typeLabel = type == ReportType.lost ? l10n.typeLost : l10n.typeFound;
    final typeTone = type == ReportType.lost
        ? StatusChipTone.error
        : StatusChipTone.success;
    final statusChip = switch (status) {
      ReportStatus.active => null,
      ReportStatus.matching => (l10n.statusMatching, StatusChipTone.primary),
      ReportStatus.recovered => (l10n.statusRecovered, StatusChipTone.success),
    };
    final dateLabel = intl.DateFormat.MMMd(l10n.localeName).format(date);
    final metaStyle = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    );

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radius.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radius.r),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox.square(
                  dimension: 96.r,
                  child: _buildThumbnail(colors),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        StatusChip(label: typeLabel, tone: typeTone),
                        if (statusChip != null)
                          StatusChip(label: statusChip.$1, tone: statusChip.$2),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: metaStyle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('·', style: metaStyle),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.r,
                          color: colors.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                        Text(dateLabel, style: metaStyle),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colors) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder(colors);

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _placeholder(colors),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _placeholder(colors),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 32.r,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
