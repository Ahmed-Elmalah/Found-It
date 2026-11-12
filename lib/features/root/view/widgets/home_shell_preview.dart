import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// A sleek scrollable preview for the Home tab demonstrating the frosted
/// Liquid Glass navigation bar with multi-layered ambient shadows and fluid scrolling.
class HomeShellPreview extends StatelessWidget {
  const HomeShellPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: colors.primary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18.r,
                              color: colors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Cairo',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20.r,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.surfaceContainerHighest
                            : colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                            blurRadius: 10.r,
                            offset: Offset(0, 3.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 22.r,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Banner / Modern depth card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF233154),
                              const Color(0xFF161E33),
                            ]
                          : [
                              const Color(0xFF2563EB),
                              const Color(0xFF1D4ED8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB)
                            .withValues(alpha: isDark ? 0.35 : 0.28),
                        blurRadius: 20.r,
                        offset: Offset(0, 8.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '✨ Liquid Glass Experience',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              l10n.appTagline,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 28.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: Text(
                  'Recent Activity in Cairo',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),

            // Scrollable sample items to test the blur underneath the Liquid Glass Dock
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final isLost = index.isEven;
                    final titles = [
                      'AirPods Pro with White Case',
                      'Brown Leather Wallet',
                      'Silver Car Keys with Remote',
                      'iPhone 14 Midnight Black',
                      'University Student ID Card',
                      'Gray Backpack with Laptop',
                    ];
                    final title = titles[index % titles.length];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: isDark ? 0.4 : 0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
                              blurRadius: 14.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64.r,
                              height: 64.r,
                              decoration: BoxDecoration(
                                color: isLost
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.10)
                                    : const Color(0xFF10B981).withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Center(
                                child: Icon(
                                  isLost
                                      ? Icons.search_rounded
                                      : Icons.check_circle_outline_rounded,
                                  color: isLost
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                  size: 28.r,
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isLost
                                              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                                              : const Color(0xFF10B981).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          isLost ? l10n.lost : l10n.found,
                                          style: TextStyle(
                                            color: isLost
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF059669),
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Today · 2 hrs ago',
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.place_outlined,
                                        size: 13.r,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        'Nasr City, Cairo',
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
                    );
                  },
                  childCount: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
