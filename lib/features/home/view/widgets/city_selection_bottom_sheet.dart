import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/city/domain/city_entity.dart';

class CitySelectionBottomSheet extends StatelessWidget {
  const CitySelectionBottomSheet({
    super.key,
    required this.currentCityId,
    required this.cities,
    required this.onCitySelected,
  });

  final String currentCityId;
  final List<CityEntity> cities;
  final ValueChanged<CityEntity> onCitySelected;

  static Future<void> show({
    required BuildContext context,
    required String currentCityId,
    required List<CityEntity> cities,
    required ValueChanged<CityEntity> onCitySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => CitySelectionBottomSheet(
        currentCityId: currentCityId,
        cities: cities,
        onCitySelected: onCitySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F2E) : theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 30.r,
            offset: Offset(0, -6.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),

              // Drag Handle
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.5.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Header Row
              Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        color: primary,
                        size: 20.r,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.homeSelectCityTitle,
                          style: TextStyle(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          l10n.homeSelectCitySubtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(18.r),
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.r,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // Dynamic City Tiles from Supabase Database
              for (final city in cities) ...[
                Builder(
                  builder: (context) {
                    final localizedName = city.localizedName(locale);
                    final secondaryName =
                        locale == 'ar' ? city.nameEn : city.nameAr;

                    final isSelected = city.id == currentCityId;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onCitySelected(city);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 13.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(
                                    alpha: isDark ? 0.16 : 0.08)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF8FAFC)),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected
                                  ? primary.withValues(
                                      alpha: isDark ? 0.45 : 0.35)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.07)
                                      : const Color(0xFFE2E8F0)),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primary.withValues(
                                          alpha: isDark ? 0.22 : 0.14)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.location_city_rounded,
                                  color: isSelected
                                      ? primary
                                      : theme.colorScheme.onSurfaceVariant,
                                  size: 19.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizedName,
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 1.5.h),
                                    Text(
                                      secondaryName,
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24.r,
                                  height: 24.r,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 15.r,
                                  ),
                                )
                              else
                                Container(
                                  width: 22.r,
                                  height: 22.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.25)
                                          : Colors.black.withValues(alpha: 0.20),
                                      width: 1.4,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              SizedBox(height: 14.h),
            ],
          ),
        ),
      ),
    );
  }
}
