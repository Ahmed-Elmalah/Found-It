import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Row comparing a single field between "Your Report" and "Matched Report".
class ComparisonFieldRow extends StatelessWidget {
  final String label;
  final String myValue;
  final String otherValue;
  final IconData? icon;

  const ComparisonFieldRow({
    super.key,
    required this.label,
    required this.myValue,
    required this.otherValue,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Label
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.r, color: colors.onSurfaceVariant),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Two-column values
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Report Value
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    myValue.isNotEmpty ? myValue : '—',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),

              // Matched Report Value
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    otherValue.isNotEmpty ? otherValue : '—',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
