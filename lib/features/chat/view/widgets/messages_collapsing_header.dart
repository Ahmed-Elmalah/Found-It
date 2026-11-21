import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class MessagesCollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  MessagesCollapsingHeaderDelegate({
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.topPadding,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final double topPadding;

  @override
  double get minExtent => topPadding + 54.h;

  @override
  double get maxExtent => topPadding + 138.h;

  @override
  bool shouldRebuild(covariant MessagesCollapsingHeaderDelegate oldDelegate) {
    return oldDelegate.searchController != searchController ||
        oldDelegate.topPadding != topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final scrollRange = maxExtent - minExtent;
    final progress = scrollRange > 0
        ? (shrinkOffset / scrollRange).clamp(0.0, 1.0)
        : 0.0;

    // Compact title fades in on collapse
    final compactTitleOpacity = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);

    // Large title & search bar fade out as header collapses
    final largeContentOpacity = (1.0 - progress * 1.6).clamp(0.0, 1.0);

    final bgColor = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.88 * progress)
        : Colors.white.withValues(alpha: 0.90 * progress);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18 * progress,
          sigmaY: 18 * progress,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: progress > 0.05 ? bgColor : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: progress > 0.8
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06))
                    : Colors.transparent,
                width: 0.8,
              ),
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Compact Header Bar (Pinned at top, visible on scroll)
              Positioned(
                top: topPadding,
                left: 0,
                right: 0,
                height: 54.h,
                child: Opacity(
                  opacity: compactTitleOpacity,
                  child: Center(
                    child: Text(
                      l10n.messagesTitle,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Expanded Header Content (Large Title + Sleek Search Bar)
              Positioned(
                top: topPadding + 4.h,
                left: 16.w,
                right: 16.w,
                bottom: 10.h,
                child: Opacity(
                  opacity: largeContentOpacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Large Bold Title
                      Text(
                        l10n.messagesTitle,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // iOS-Style Search Bar
                      Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.search_rounded,
                              size: 19.sp,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: onSearchChanged,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: l10n.messagesSearchPlaceholder,
                                  hintStyle: TextStyle(
                                    fontSize: 13.5.sp,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: searchController,
                              builder: (context, value, _) {
                                if (value.text.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    searchController.clear();
                                    onClearSearch();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                    ),
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      size: 18.sp,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
