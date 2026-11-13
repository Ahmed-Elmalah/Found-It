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
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

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
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
              child: const HomeHeroBanner()
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: -0.08, end: 0, curve: Curves.easeOutCubic),
            ),
          ),

          // 2. Section Header: Recent Activity in [City] + Community Trust Badge
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeRecentActivity(cityName),
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      // Community Trust Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(
                            alpha: isDark ? 0.16 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(
                              alpha: isDark ? 0.28 : 0.18,
                            ),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 13.5.r,
                              color: const Color(0xFF10B981),
                            ),
                            SizedBox(width: 4.5.w),
                            Text(
                              locale == 'ar' ? 'مجتمع موثوق' : 'Verified Community',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    locale == 'ar'
                        ? 'كل المعثورات مؤمنة ومعلنة من أفراد المجتمع في $cityName'
                        : 'All found items are securely reported by the community in $cityName',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.70),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
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
                    bottom: 12.h,
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
