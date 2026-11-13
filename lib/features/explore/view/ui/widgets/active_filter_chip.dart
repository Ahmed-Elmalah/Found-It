import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pill used in the active filters row under the search field (Figma P19).
///
/// The selected category uses a solid primary background; date / city filters
/// are outlined and show a close icon to remove them.
class ActiveFilterChip extends StatelessWidget {
  const ActiveFilterChip({
    super.key,
    required this.label,
    this.isPrimary = false,
    this.onRemove,
  });

  /// Already localized label.
  final String label;

  /// Solid primary style (used for the category filter).
  final bool isPrimary;

  /// When set, a close icon is shown and the whole chip is tappable.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isPrimary ? colors.primary : colors.surface;
    final foreground = isPrimary ? colors.onPrimary : colors.onSurface;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onRemove != null) ...[
          SizedBox(width: 4.w),
          Icon(
            Icons.close_rounded,
            size: 16.r,
            color: isPrimary ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ],
      ],
    );

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(100.r),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(100.r),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 14.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            border: isPrimary ? null : Border.all(color: colors.outline),
          ),
          child: content,
        ),
      ),
    );
  }
}
