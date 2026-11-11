import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/report_status.dart';
import 'package:found_it/core/widgets/status_chip.dart';

/// Shared report item card, reused by the Home, Explore (search results)
/// and My Reports screens.
///
/// Horizontal layout: image on the leading edge, then the title, an embedded
/// [StatusChip] and a location + date meta row (Figma P19/P52).
///
/// Pure UI: every value comes from the constructor, so the card can be fed
/// by mock data now and by real report models later.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.title,
    required this.status,
    this.location,
    this.date,
    this.imageUrl,
    this.onTap,
  });

  /// Report title, capped at two lines.
  final String title;

  /// Status rendered as an embedded [StatusChip].
  final ReportStatus status;

  /// Location / district line, e.g. "Nasr City". Hidden when null.
  final String? location;

  /// Report date, formatted with the active locale. Hidden when null.
  final DateTime? date;

  /// Network image of the report. Falls back to a themed placeholder.
  final String? imageUrl;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radius.r),
        side: BorderSide(color: colors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(colors),
              SizedBox(width: 12.w),
              Expanded(child: _buildDetails(context, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme colors) {
    final url = imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox.square(
        dimension: 96.r,
        child: url == null
            ? _imagePlaceholder(colors)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(colors),
              ),
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme colors) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 24.r,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, ColorScheme colors) {
    final l10n = AppLocalizations.of(context);
    final hasMeta = location != null || date != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        SizedBox(height: 6.h),
        StatusChip(text: status.label(l10n), color: status.color(context)),
        if (hasMeta) ...[SizedBox(height: 8.h), _buildMetaRow(l10n, colors)],
      ],
    );
  }

  Widget _buildMetaRow(AppLocalizations l10n, ColorScheme colors) {
    final place = location;
    final when = date;
    final style = TextStyle(
      color: colors.onSurfaceVariant,
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        if (place != null) ...[
          Icon(
            Icons.location_on_outlined,
            size: 14.r,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              place,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
        if (place != null && when != null) SizedBox(width: 10.w),
        if (when != null) ...[
          Icon(
            Icons.calendar_today_outlined,
            size: 14.r,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(width: 4.w),
          Text(
            intl.DateFormat.MMMd(l10n.localeName).format(when),
            maxLines: 1,
            style: style,
          ),
        ],
      ],
    );
  }
}
