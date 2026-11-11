import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small tinted pill that displays a report status, e.g. "Lost" or "Found".
///
/// Pure presentation: it only paints what it is given. The status semantics
/// (localized label + light/dark aware color) live in [ReportStatus], so the
/// chip itself stays reusable for any colored tag.
///
/// The background is a soft tint of [color] while the text uses [color] at
/// full opacity (soft-chip style, Figma P19/P52). Pass the light or dark
/// variant of the color from the caller, resolved via `Theme.of(context)` or
/// the central palette in `AppColors`.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.text,
    required this.color,
    this.padding,
  });

  /// Localized label shown inside the chip.
  final String text;

  /// Base color of the chip for the current theme.
  final Color color;

  /// Inner padding of the pill. Defaults to a compact pill shape.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
