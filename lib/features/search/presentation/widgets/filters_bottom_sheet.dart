import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/theme/app_theme.dart';
import 'package:found_it/core/widgets/report_category.dart';

/// Filter values carried between the Explore screen and the filter sheet.
///
/// Simple mutable view state on purpose - no Cubit and no backend in this
/// task (pure UI, mock data only).
class ExploreFilters {
  ExploreFilters({this.category, this.startDate, this.endDate, this.city});

  ReportCategory? category;
  DateTime? startDate;
  DateTime? endDate;
  String? city;

  bool get hasAny =>
      category != null ||
      startDate != null ||
      endDate != null ||
      (city != null && city!.trim().isNotEmpty);
}

/// Multi-filter bottom sheet of the Explore screen (Figma P20, light mode).
///
/// Pure UI with local state only: it edits a copy of the incoming filters and
/// pops the result back to the caller via `Navigator.pop`.
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key, required this.initialFilters});

  final ExploreFilters initialFilters;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  ReportCategory? _category;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category = widget.initialFilters.category;
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _cityController.text = widget.initialFilters.city ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? _startDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      _category = null;
      _startDate = null;
      _endDate = null;
    });
    _cityController.clear();
  }

  void _apply() {
    Navigator.of(context).pop(
      ExploreFilters(
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
        city: _cityController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSizes.pagePadding.w,
          8.h,
          AppSizes.pagePadding.w,
          24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filtersTitle,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24.h),
            _sectionLabel(l10n.categoryLabel, colors),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final category in ReportCategory.values)
                  _CategoryChip(
                    label: category.label(l10n),
                    selected: category == _category,
                    onTap: () => setState(
                      () => _category = category == _category ? null : category,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 24.h),
            _sectionLabel(l10n.dateRangeLabel, colors),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    value: _formatDate(l10n, _startDate),
                    hint: l10n.startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _DateField(
                    value: _formatDate(l10n, _endDate),
                    hint: l10n.endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _sectionLabel(l10n.cityLabel, colors),
            SizedBox(height: 12.h),
            TextField(
              controller: _cityController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(hintText: l10n.cityLabel),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: Text(l10n.reset),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(l10n.showResults),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(AppLocalizations l10n, DateTime? date) {
    if (date == null) return '';
    return intl.DateFormat.yMMMd(l10n.localeName).format(date);
  }

  Widget _sectionLabel(String label, ColorScheme colors) {
    return Text(
      label,
      style: TextStyle(
        color: colors.onSurface,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Selectable category chip: solid primary background with white text when
/// selected, clean outline border otherwise (Figma P20).
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radius.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radius.r),
          border: selected
              ? null
              : Border.fromBorderSide(BorderSide(color: colors.outline)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Read-only, text-field-like box for one end of the date range. Tapping it
/// opens the Material date picker; the look comes from the input theme.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: InputDecorator(
        decoration: InputDecoration(hintText: hint),
        child: Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
