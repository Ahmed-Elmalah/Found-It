import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 4.w,
        top: 20.h,
        bottom: 8.h,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: colors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
