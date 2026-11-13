import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/city/domain/city_entity.dart';

/// Predefined list of Egyptian governorates & major cities with English & Arabic names.
const List<CityEntity> kEgyptianCities = [
  CityEntity(id: 'cairo', nameEn: 'Cairo', nameAr: 'القاهرة', sortOrder: 1),
  CityEntity(id: 'giza', nameEn: 'Giza', nameAr: 'الجيزة', sortOrder: 2),
  CityEntity(id: 'alexandria', nameEn: 'Alexandria', nameAr: 'الإسكندرية', sortOrder: 3),
  CityEntity(id: 'dakahlia', nameEn: 'Mansoura', nameAr: 'المنصورة', sortOrder: 4),
  CityEntity(id: 'gharbia', nameEn: 'Tanta', nameAr: 'طنطا', sortOrder: 5),
  CityEntity(id: 'sharqia', nameEn: 'Zagazig', nameAr: 'الزقازيق', sortOrder: 6),
  CityEntity(id: 'qalyubia', nameEn: 'Banha', nameAr: 'بنها', sortOrder: 7),
  CityEntity(id: 'portsaid', nameEn: 'Port Said', nameAr: 'بورسعيد', sortOrder: 8),
  CityEntity(id: 'ismailia', nameEn: 'Ismailia', nameAr: 'الإسماعيلية', sortOrder: 9),
  CityEntity(id: 'suez', nameEn: 'Suez', nameAr: 'السويس', sortOrder: 10),
  CityEntity(id: 'asyut', nameEn: 'Asyut', nameAr: 'أسيوط', sortOrder: 11),
  CityEntity(id: 'sohag', nameEn: 'Sohag', nameAr: 'سوهاج', sortOrder: 12),
  CityEntity(id: 'minya', nameEn: 'Minya', nameAr: 'المنيا', sortOrder: 13),
  CityEntity(id: 'luxor', nameEn: 'Luxor', nameAr: 'الأقصر', sortOrder: 14),
  CityEntity(id: 'aswan', nameEn: 'Aswan', nameAr: 'أسوان', sortOrder: 15),
  CityEntity(id: 'redsea', nameEn: 'Hurghada', nameAr: 'الغردقة', sortOrder: 16),
  CityEntity(id: 'southsinai', nameEn: 'Sharm El Sheikh', nameAr: 'شرم الشيخ', sortOrder: 17),
];

class CitySelectionBottomSheet extends StatefulWidget {
  const CitySelectionBottomSheet({
    super.key,
    required this.currentCity,
    required this.onCitySelected,
    this.availableCities = kEgyptianCities,
  });

  final String currentCity;
  final ValueChanged<String> onCitySelected;
  final List<CityEntity> availableCities;

  static Future<void> show({
    required BuildContext context,
    required String currentCity,
    required ValueChanged<String> onCitySelected,
    List<CityEntity>? availableCities,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => CitySelectionBottomSheet(
        currentCity: currentCity,
        onCitySelected: onCitySelected,
        availableCities: availableCities ?? kEgyptianCities,
      ),
    );
  }

  @override
  State<CitySelectionBottomSheet> createState() =>
      _CitySelectionBottomSheetState();
}

class _CitySelectionBottomSheetState extends State<CitySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Filter cities based on search query
    final filteredCities = widget.availableCities.where((city) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return city.nameAr.toLowerCase().contains(q) ||
          city.nameEn.toLowerCase().contains(q);
    }).toList();

    final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;

    return Container(
      height: sheetHeight,
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
      child: Column(
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

          SizedBox(height: 14.h),

          // Header Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
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
          ),

          SizedBox(height: 16.h),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.search_rounded,
                    size: 20.r,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.homeSearchCityHint,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.65),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    InkWell(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 18.r,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // City List
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Text(
                      l10n.homeNoCitiesFound,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 6.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final localizedName = city.localizedName(locale);
                      final secondaryName =
                          locale == 'ar' ? city.nameEn : city.nameAr;

                      final isSelected = widget.currentCity == localizedName ||
                          widget.currentCity == city.nameAr ||
                          widget.currentCity == city.nameEn;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onCitySelected(localizedName);
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withValues(
                                      alpha: isDark ? 0.16 : 0.08)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.03)
                                      : Colors.black.withValues(alpha: 0.02)),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? primary
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.black.withValues(alpha: 0.04)),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? primary
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.06)
                                            : Colors.black
                                                .withValues(alpha: 0.04)),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.location_city_rounded,
                                      size: 17.r,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      SizedBox(height: 2.h),
                                      Text(
                                        secondaryName,
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          color: theme
                                              .colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 22.r,
                                    height: 22.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primary,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 15,
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
          ),

          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
