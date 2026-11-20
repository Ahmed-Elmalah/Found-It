import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/status_chip.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/view/widgets/match_score_badge.dart';

/// Card displaying a potential match (Figma P28 / P62).
class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback onViewMatch;
  final VoidCallback onDismiss;

  const MatchCard({
    super.key,
    required this.match,
    required this.onViewMatch,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final other = match.otherReport;
    final title = other?.title ?? match.otherUserName;
    final isLost = other?.type == 'lost';
    final typeLabel = isLost ? l10n.typeLost : l10n.typeFound;
    final typeTone = isLost ? StatusChipTone.error : StatusChipTone.success;

    final locationParts = [
      if (other != null) other.localizedArea(locale),
      if (other != null) other.localizedCity(locale),
    ].where((p) => p.isNotEmpty).join(', ');

    final dateLabel = other != null
        ? intl.DateFormat.MMMd(l10n.localeName).format(other.itemDate)
        : '';

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radius.r),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius.r),
          border: Border.all(color: colors.outline),
        ),
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar: Type Chip + Similarity Badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusChip(label: typeLabel, tone: typeTone),
                if (match.isAuto && match.similarity > 0)
                  MatchScoreBadge(similarity: match.similarity),
              ],
            ),
            SizedBox(height: 12.h),

            // ── Main Content: Image + Details ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: 76.w,
                    height: 76.w,
                    color: colors.surfaceContainerHighest,
                    child: other?.image != null && other!.image!.isNotEmpty
                        ? Image.network(
                            other.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.broken_image_rounded,
                              color: colors.onSurfaceVariant,
                              size: 28.r,
                            ),
                          )
                        : Icon(
                            Icons.inventory_2_outlined,
                            color: colors.onSurfaceVariant,
                            size: 28.r,
                          ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      if (other != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 13.r,
                              color: colors.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                other.localizedCategory(locale),
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
                        SizedBox(height: 3.h),
                      ],
                      if (locationParts.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13.r,
                              color: colors.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                locationParts,
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
                        SizedBox(height: 3.h),
                      ],
                      if (dateLabel.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12.r,
                              color: colors.onSurfaceVariant,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              dateLabel,
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
            SizedBox(height: 14.h),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      side: BorderSide(color: colors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      l10n.dismiss,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 3,
                  child: FilledButton(
                    onPressed: onViewMatch,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      l10n.viewMatch,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
