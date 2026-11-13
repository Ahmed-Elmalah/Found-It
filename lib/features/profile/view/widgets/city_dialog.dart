import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/profile/domain/entities/city_entity.dart';

class CityDialog extends StatelessWidget {
  const CityDialog({
    super.key,
    required this.cities,
    required this.selectedCityId,
    required this.onCitySelected,
  });

  final List<CityEntity> cities;
  final String? selectedCityId;
  final ValueChanged<String> onCitySelected;

  static Future<void> show(
    BuildContext context, {
    required List<CityEntity> cities,
    required String? selectedCityId,
    required ValueChanged<String> onCitySelected,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CityDialog(
        cities: cities,
        selectedCityId: selectedCityId,
        onCitySelected: onCitySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

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
              l10n.selectCity,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            ...cities.map((city) {
              final isSelected = city.id == selectedCityId;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                leading: Icon(
                  Icons.location_city_rounded,
                  color: isSelected ? colors.primary : colors.onSurfaceVariant,
                ),
                title: Text(
                  city.localizedName(locale),
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
                  onCitySelected(city.id);
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
