import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/features/explore/view/cubit/search_state.dart';

/// Values returned by [FiltersBottomSheet]. `null` / empty means "no filter".
class ExploreFilters {
  const ExploreFilters({
    this.type,
    this.categoryIds = const [],
    this.areaIds = const [],
    this.dateFrom,
    this.dateTo,
  });

  final ReportType? type;
  final List<String> categoryIds;
  final List<String> areaIds;
  final DateTime? dateFrom;
  final DateTime? dateTo;
}

/// Filters sheet (Figma P20 / P53): type, categories, areas, date range, city
/// and the Reset / Show results actions.
class FiltersBottomSheet extends StatefulWidget {
  const FiltersBottomSheet({
    super.key,
    required this.categories,
    required this.areas,
    required this.cityName,
    this.initialType,
    this.initialCategoryIds = const [],
    this.initialAreaIds = const [],
    this.initialDateFrom,
    this.initialDateTo,
  });

  final List<CategoryOption> categories;
  final List<AreaOption> areas;

  /// The user's city name (already localized). The field is read only: the
  /// search always stays inside that city.
  final String cityName;

  final ReportType? initialType;
  final List<String> initialCategoryIds;
  final List<String> initialAreaIds;
  final DateTime? initialDateFrom;
  final DateTime? initialDateTo;

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late ReportType? _type;
  late Set<String> _categoryIds;
  late Set<String> _areaIds;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;

  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _cityController = TextEditingController();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _categoryIds = {...widget.initialCategoryIds};
    _areaIds = {...widget.initialAreaIds};
    _dateFrom = widget.initialDateFrom;
    _dateTo = widget.initialDateTo;
    _cityController.text = widget.cityName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The localized date format needs Localizations, which is only available
    // from didChangeDependencies onwards.
    if (_initialized) return;
    _initialized = true;
    _syncDateControllers();
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _syncDateControllers() {
    final locale = AppLocalizations.of(context).localeName;
    final format = intl.DateFormat.MMMd(locale);
    _startController.text = _dateFrom == null ? '' : format.format(_dateFrom!);
    _endController.text = _dateTo == null ? '' : format.format(_dateTo!);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final current = isStart ? _dateFrom : _dateTo;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
      _syncDateControllers();
    });
  }

  void _reset() {
    setState(() {
      _type = null;
      _categoryIds = {};
      _areaIds = {};
      _dateFrom = null;
      _dateTo = null;
      _syncDateControllers();
    });
  }

  void _showResults() {
    Navigator.of(context).pop(
      ExploreFilters(
        type: _type,
        categoryIds: _categoryIds.toList(),
        areaIds: _areaIds.toList(),
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 4.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.filtersTitle,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            _Label(l10n.reportTypeLabel),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _FilterChip(
                  label: l10n.tabAll,
                  isSelected: _type == null,
                  onTap: () => setState(() => _type = null),
                ),
                _FilterChip(
                  label: l10n.typeLost,
                  isSelected: _type == ReportType.lost,
                  onTap: () => setState(
                    () => _type = _type == ReportType.lost
                        ? null
                        : ReportType.lost,
                  ),
                ),
                _FilterChip(
                  label: l10n.typeFound,
                  isSelected: _type == ReportType.found,
                  onTap: () => setState(
                    () => _type = _type == ReportType.found
                        ? null
                        : ReportType.found,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _Label(l10n.categoryLabel),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final category in widget.categories)
                  _FilterChip(
                    label: category.name(l10n.localeName),
                    isSelected: _categoryIds.contains(category.id),
                    onTap: () => setState(() {
                      if (!_categoryIds.remove(category.id)) {
                        _categoryIds.add(category.id);
                      }
                    }),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            _Label(l10n.areaLabel),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final area in widget.areas)
                  _FilterChip(
                    label: area.name(l10n.localeName),
                    isSelected: _areaIds.contains(area.id),
                    onTap: () => setState(() {
                      if (!_areaIds.remove(area.id)) {
                        _areaIds.add(area.id);
                      }
                    }),
                  ),
              ],
            ),
            SizedBox(height: 20.h),
            _Label(l10n.dateRangeLabel),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    controller: _startController,
                    hint: l10n.startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DateField(
                    controller: _endController,
                    hint: l10n.endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _Label(l10n.cityLabel),
            SizedBox(height: 10.h),
            TextField(
              controller: _cityController,
              readOnly: true,
              enableInteractiveSelection: false,
              style: TextStyle(fontSize: 16.sp, color: colors.onSurface),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.reset,
                    variant: AppButtonVariant.outlined,
                    onPressed: _reset,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppButton(
                    label: l10n.showResults,
                    onPressed: _showResults,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(100.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.r),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 14.w,
            vertical: 8.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            border: isSelected ? null : Border.all(color: colors.outline),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.onPrimary : colors.onSurface,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.hint,
    required this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(fontSize: 16.sp, color: colors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 16.sp, color: colors.onSurfaceVariant),
      ),
    );
  }
}
