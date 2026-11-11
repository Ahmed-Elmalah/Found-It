import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Removable filter chip shown in the active filters row of the Explore
/// screen (Figma P19, light mode).
///
/// [filled] marks the category filter (solid blue, white text); the date
/// range and city chips use the outlined style.
class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.onRemove,
    this.filled = false,
  });

  /// Text shown inside the chip (already localized).
  final String label;

  /// Called when the remove (X) icon is tapped.
  final VoidCallback onRemove;

  /// Solid primary background with white text when true, outlined otherwise.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final contentColor = filled ? colors.onPrimary : colors.onSurface;

    return Container(
      height: 34.h,
      padding: EdgeInsetsDirectional.only(start: 12.w, end: 4.w),
      decoration: BoxDecoration(
        color: filled ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(100.r),
        border: filled
            ? null
            : Border.fromBorderSide(BorderSide(color: colors.outline)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: contentColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
              child: Icon(
                Icons.close,
                size: 16.r,
                color: filled ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
