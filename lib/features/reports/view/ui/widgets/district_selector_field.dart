import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/domain/entities/area_entity.dart';

/// A tappable field that opens a bottom-sheet list for picking an area / district.
class DistrictSelectorField extends StatelessWidget {
  final List<AreaEntity> areas;
  final String? selectedId;
  final String? errorText;
  final ValueChanged<String> onSelected;

  const DistrictSelectorField({
    super.key,
    required this.areas,
    required this.selectedId,
    required this.onSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final hasError = errorText != null;

    final selectedArea = areas.where((a) => a.id == selectedId).firstOrNull;
    final displayText = selectedArea?.localizedName(locale) ?? l10n.selectDistrict;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: l10n.locationDistrict,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: hasError ? colors.error : colors.onSurface,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showSheet(context),
          child: Container(
            height: 56.h,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasError ? colors.error : colors.outline,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20.r,
                  color: hasError
                      ? colors.error
                      : colors.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: selectedArea != null
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 14.r,
                color: colors.error,
              ),
              SizedBox(width: 4.w),
              Text(
                errorText!,
                style: TextStyle(fontSize: 12.sp, color: colors.error),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _showSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 4.h, 20.w, 12.h),
                child: Text(
                  l10n.locationDistrict,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: areas.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, index) {
                    final area = areas[index];
                    final isSelected = selectedId == area.id;
                    return ListTile(
                      title: Text(
                        area.localizedName(locale),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: colors.primary,
                              size: 20.r,
                            )
                          : null,
                      onTap: () {
                        onSelected(area.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
