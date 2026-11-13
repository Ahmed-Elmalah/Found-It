import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeShimmerView extends StatelessWidget {
  const HomeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF161F2E) : Colors.white;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Shimmer Hero Banner
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 18.h),
            child: Container(
              height: 140.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: baseColor,
              ),
            ),
          ),

          // 2. Section Title Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: 170.w,
              height: 18.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: baseColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 3. Feed Card Skeletons (4 cards)
          for (int i = 0; i < 4; i++)
            _buildCardSkeleton(baseColor, cardBg, isDark),

          SizedBox(height: 110.h),
        ],
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1400.ms,
            color: highlightColor.withValues(alpha: isDark ? 0.40 : 0.70),
            curve: Curves.easeInOutSine,
          ),
    );
  }

  Widget _buildCardSkeleton(Color baseColor, Color cardBg, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: cardBg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail box
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              color: baseColor,
            ),
          ),
          SizedBox(width: 14.w),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag + Date row
                Row(
                  children: [
                    Container(
                      width: 52.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: baseColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 48.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: baseColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Title skeleton
                Container(
                  width: 160.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    color: baseColor,
                  ),
                ),
                SizedBox(height: 8.h),

                // Location skeleton
                Container(
                  width: 110.w,
                  height: 11.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    color: baseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
