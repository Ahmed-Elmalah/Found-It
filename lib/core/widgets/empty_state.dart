import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/theme/app_theme.dart';

/// Centered empty-state view shown when a list has no results, e.g. the
/// Explore search results (Figma P56 / P17, light mode).
///
/// Hierarchy: soft circular icon container, bold heading, muted message.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.search_off,
    this.action,
  });

  /// Bold heading line, e.g. "No matching reports found."
  final String title;

  /// Muted supporting line, e.g. "Try adjusting your search filters."
  final String message;

  /// Icon shown inside the circular container.
  final IconData icon;

  /// Optional call-to-action shown below the message, e.g. "Create report".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 48.r, color: colors.onSurfaceVariant),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            if (action != null) ...[SizedBox(height: 24.h), action!],
          ],
        ),
      ),
    );
  }
}
