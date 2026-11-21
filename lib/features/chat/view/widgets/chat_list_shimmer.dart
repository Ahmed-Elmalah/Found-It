import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF161F2E) : Colors.white;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          for (int i = 0; i < 5; i++) ...[
            Container(
              padding: EdgeInsets.all(14.r),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: cardBg,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                ),
              ),
              child: Row(
                children: [
                  // Avatar Shimmer
                  Container(
                    width: 66.r,
                    height: 66.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: baseColor,
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Content Shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Tag & Date
                        Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.r),
                                color: baseColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 42.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: baseColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),

                        // Row 2: Name
                        Container(
                          width: 130.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            color: baseColor,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Row 3: Message preview
                        Container(
                          width: 190.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.r),
                            color: baseColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 1200.ms,
            color: highlightColor.withValues(alpha: 0.5),
          ),
    );
  }
}
