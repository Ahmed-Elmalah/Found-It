import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/domain/entities/report_counts_entity.dart';
import 'package:found_it/features/reports/view/cubit/my_reports_state.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.selectedFilter,
    required this.counts,
    required this.onFilterSelected,
  });

  final MyReportsFilter selectedFilter;
  final ReportCountsEntity counts;
  final ValueChanged<MyReportsFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    final tabs = [
      (MyReportsFilter.all, l10n.tabAll, counts.total),
      (MyReportsFilter.active, l10n.tabActive, counts.active),
      (MyReportsFilter.matching, l10n.tabMatching, counts.matching),
      (MyReportsFilter.recovered, l10n.tabRecovered, counts.recovered),
    ];

    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final (filter, label, count) = tabs[index];
          final isSelected = filter == selectedFilter;

          return InkWell(
            onTap: () => onFilterSelected(filter),
            borderRadius: BorderRadius.circular(22.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: 14.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.outline,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.onPrimary.withValues(alpha: 0.2)
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
