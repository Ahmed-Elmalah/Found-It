import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// A tappable field that opens the system date picker.
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final formatted = DateFormat('MMM d, yyyy').format(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.date,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            height: 56.h,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) onDateSelected(picked);
  }
}
