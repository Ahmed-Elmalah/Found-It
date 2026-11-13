import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import '../../domain/entities/home_report_item.dart';
import 'home_feed_item_card.dart';
import 'home_hero_banner.dart';

class HomeSuccessView extends StatelessWidget {
  const HomeSuccessView({
    super.key,
    required this.cityName,
    required this.reports,
    required this.onRefresh,
    this.onItemTap,
  });

  final String cityName;
  final List<HomeReportItem> reports;
  final Future<void> Function() onRefresh;
  final ValueChanged<HomeReportItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
          SliverToBoxAdapter(child: SizedBox(height: 14.h)),

          // 3. Staggered Feed List with flutter_animate
          if (reports.isEmpty)
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
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final item = reports[index];

                return Padding(
                  padding: EdgeInsets.only(
                    left: 20.w,
                    right: 20.w,
                    bottom: 14.h,
                  ),
                  child: HomeFeedItemCard(
                    item: item,
                    onTap: () => onItemTap?.call(item),
                  )
                      .animate(
                        delay: Duration(milliseconds: 50 * index),
                      )
                      .fadeIn(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                      ),
                );
              },
            ),

          // 4. Bottom clearance for floating Liquid Glass Dock
          SliverToBoxAdapter(
            child: SizedBox(height: 110.h),
          ),
        ],
      ),
    );
  }
}
