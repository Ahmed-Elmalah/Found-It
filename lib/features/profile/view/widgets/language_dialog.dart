import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/preferences/app_preferences_cubit.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LanguageDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final cubit = context.read<AppPreferencesCubit>();
    final currentLocale = cubit.state.locale;

    final options = [
      (null, l10n.languageSystem, '🌐'),
      (const Locale('en'), l10n.languageEnglish, '🇺🇸'),
      (const Locale('ar'), l10n.languageArabic, '🇪🇬'),
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      backgroundColor: colors.surface,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Padding(
        padding: EdgeInsetsDirectional.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.languageLabel,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            ...options.map((option) {
              final (locale, title, flag) = option;
              final isSelected = locale == null
                  ? currentLocale == null
                  : currentLocale?.languageCode == locale.languageCode;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                leading: Text(flag, style: TextStyle(fontSize: 22.sp)),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? colors.primary : colors.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: colors.primary)
                    : null,
                onTap: () {
                  cubit.setLocale(locale);
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
