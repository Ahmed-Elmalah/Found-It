import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import '../../domain/entities/home_report_item.dart';
import 'home_feed_item_card.dart';
import 'home_filter_chips.dart';
import 'home_hero_banner.dart';

class HomeSuccessView extends StatelessWidget {
  const HomeSuccessView({
    super.key,
    required this.cityName,
    required this.reports,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onRefresh,
    this.onItemTap,
  });

  final String cityName;
  final List<HomeReportItem> reports;
  final HomeFilterType selectedFilter;
  final ValueChanged<HomeFilterType> onFilterSelected;
  final Future<void> Function() onRefresh;
  final ValueChanged<HomeReportItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Calculate filter counts
    final allCount = reports.length;
    final lostCount = reports.where((r) => r.isLost).length;
    final foundCount = reports.where((r) => r.isFound).length;

    // Filter items according to active chip
    final filteredReports = switch (selectedFilter) {
      HomeFilterType.all => reports,
      HomeFilterType.lost => reports.where((r) => r.isLost).toList(),
      HomeFilterType.found => reports.where((r) => r.isFound).toList(),
    };

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      displacement: 24.h,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // 1. Hero Action Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 18.h),
              child: const HomeHeroBanner()
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: -0.08, end: 0, curve: Curves.easeOutCubic),
            ),
          ),

          // 2. Section Header: Recent Activity in [City]
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                l10n.homeRecentActivity(cityName),
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),

          // 3. Filter Chips (All, Lost, Found)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: HomeFilterChips(
                selectedFilter: selectedFilter,
                onFilterSelected: onFilterSelected,
                allCount: allCount,
                lostCount: lostCount,
                foundCount: foundCount,
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 10.h)),

          // 4. Staggered Feed List with flutter_animate
          if (filteredReports.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                child: Center(
                  child: Text(
                    l10n.homeEmptyTitle(cityName),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final item = filteredReports[index];

                return HomeFeedItemCard(
                  item: item,
                  onTap: () => onItemTap?.call(item),
                )
                    .animate(
                      key: ValueKey('${item.id}_${selectedFilter.name}'),
                      delay: (index * 60).clamp(0, 420).ms,
                    )
                    .fadeIn(
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.16,
                      end: 0,
                      duration: 380.ms,
                      curve: Curves.easeOutCubic,
                    );
              },
            ),

          // Bottom padding to clear the floating Liquid Glass Bottom Bar
          SliverToBoxAdapter(
            child: SizedBox(height: 110.h),
          ),
        ],
      ),
    );
  }
}
