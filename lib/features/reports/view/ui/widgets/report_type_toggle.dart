import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// Full-width pill toggle between "Lost" and "Found".
/// Both segments use [ColorScheme.primary] when selected per Figma design.
class ReportTypeToggle extends StatelessWidget {
  final bool isLost;
  final ValueChanged<bool> onChanged;

  const ReportTypeToggle({
    super.key,
    required this.isLost,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lostColor = colors.error;
    final onLostColor = colors.onError;
    final foundColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF1E8E3E);
    final onFoundColor = isDark ? const Color(0xFF0F1218) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportType,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              _Tab(
                label: l10n.lost,
                isActive: isLost,
                activeColor: lostColor,
                onActiveColor: onLostColor,
                onTap: () => onChanged(true),
              ),
              _Tab(
                label: l10n.found,
                isActive: !isLost,
                activeColor: foundColor,
                onActiveColor: onFoundColor,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color onActiveColor;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onActiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isActive ? onActiveColor : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
