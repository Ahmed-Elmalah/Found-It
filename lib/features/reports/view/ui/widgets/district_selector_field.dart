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
  final bool isLoading;

  const DistrictSelectorField({
    super.key,
    required this.areas,
    required this.selectedId,
    required this.onSelected,
    this.errorText,
    this.isLoading = false,
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
          onTap: isLoading ? null : () => _showSheet(context),
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
                      : (selectedArea != null
                          ? colors.primary
                          : colors.onSurfaceVariant),
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
                if (isLoading)
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  )
                else
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DistrictSheet(
        areas: areas,
        selectedId: selectedId,
        onSelected: onSelected,
      ),
    );
  }
}

class _DistrictSheet extends StatefulWidget {
  final List<AreaEntity> areas;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _DistrictSheet({
    required this.areas,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_DistrictSheet> createState() => _DistrictSheetState();
}

class _DistrictSheetState extends State<_DistrictSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final filtered = widget.areas.where((a) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase().trim();
      return a.nameEn.toLowerCase().contains(q) || a.nameAr.contains(q);
    }).toList();

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 8.h),
              child: Text(
                l10n.locationDistrict,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ),
            if (widget.areas.length > 5)
              Padding(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 6.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintText: locale.startsWith('ar') ? 'بحث في المناطق...' : 'Search districts...',
                    contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 10.h),
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (ctx, index) {
                  final area = filtered[index];
                  final isSelected = widget.selectedId == area.id;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: isSelected ? colors.primary : colors.onSurfaceVariant,
                      size: 20.r,
                    ),
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
                      widget.onSelected(area.id);
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
    );
  }
}
