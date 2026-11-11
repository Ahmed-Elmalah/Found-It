import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The dots under the onboarding pages; the current one is a wide pill.
///
///   PageIndicator(count: 3, current: pageIndex)
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: i == current ? 24.w : 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: i == current ? colors.primary : colors.outline,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ],
    );
  }
}
