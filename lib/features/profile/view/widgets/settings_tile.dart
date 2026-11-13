import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final iconBgColor = isDestructive
        ? colors.error.withValues(alpha: 0.1)
        : colors.surfaceContainerHighest;

    final iconColor = isDestructive ? colors.error : colors.primary;
    final titleColor = isDestructive ? colors.error : colors.onSurface;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.r,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
                if (value != null && value!.isNotEmpty) ...[
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
