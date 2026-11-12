import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Semantic tone of a [StatusChip].
enum StatusChipTone { error, success, primary }

/// Soft tinted pill used for the report type and report status chips.
///
/// The background is the tone color at 12% opacity and the label uses the
/// same color at full strength.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone});

  /// Text inside the chip (already localized).
  final String label;

  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (tone) {
      StatusChipTone.error => colors.error,
      StatusChipTone.primary => colors.primary,
      // The color schemes have no dedicated success slot, so success uses
      // the primary tone instead of a hardcoded color.
      StatusChipTone.success => colors.primary,
    };

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
