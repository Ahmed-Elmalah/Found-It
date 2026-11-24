import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';
import 'package:found_it/features/matches/view/widgets/match_score_badge.dart';

/// Modular section designed to be embedded in the owner's Report Details screen.
/// Displays a summary of potential matches and a shortcut to view them.
class PotentialMatchesSection extends StatelessWidget {
  final List<MatchEntity> matches;
  final VoidCallback onViewAll;
  final ValueChanged<MatchEntity> onSelectMatch;

  const PotentialMatchesSection({
    super.key,
    required this.matches,
    required this.onViewAll,
    required this.onSelectMatch,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                l10n.potentialMatchesSectionTitle(matches.length),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAllMatches,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // Horizontal Matches Preview List
        SizedBox(
          height: 120.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final match = matches[index];
              final other = match.otherReport;
              final title = other?.title ?? match.otherUserName;

              return InkWell(
                onTap: () => onSelectMatch(match),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 200.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (match.isAuto && match.similarity > 0)
                            MatchScoreBadge(similarity: match.similarity),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.r,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      if (other != null)
                        Text(
                          other.localizedArea(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
