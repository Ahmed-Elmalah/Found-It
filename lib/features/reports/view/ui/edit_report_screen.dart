import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:found_it/core/constants/app_limits.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/edit_report_state.dart';

class EditReportScreen extends StatefulWidget {
  const EditReportScreen({
    super.key,
    required this.report,
  });

  final ReportEntity report;

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController =
        TextEditingController(text: widget.report.description ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        context.read<EditReportCubit>().init(lang: lang);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<EditReportCubit>();
    final success = await cubit.submit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (success && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportUpdatedSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(true);
    }
  }

  Future<void> _pickDate(DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      context.read<EditReportCubit>().dateChanged(picked);
    }
  }

  static String _mapFailureTitle(ReportFailureType type, AppLocalizations l10n) {
    switch (type) {
      case ReportFailureType.network:
        return l10n.connectionErrorTitle;
      case ReportFailureType.notLoggedIn:
        return l10n.notLoggedInTitle;
      case ReportFailureType.invalidData:
        return l10n.invalidDataTitle;
      case ReportFailureType.unknown:
        return l10n.genericErrorTitle;
    }
  }

  static String _mapFailureMessage(ReportFailureType type, AppLocalizations l10n) {
    switch (type) {
      case ReportFailureType.network:
        return l10n.connectionErrorMessage;
      case ReportFailureType.notLoggedIn:
        return l10n.notLoggedInMessage;
      case ReportFailureType.invalidData:
        return l10n.invalidDataMessage;
      case ReportFailureType.unknown:
        return l10n.genericErrorMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editReportTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocConsumer<EditReportCubit, EditReportState>(
        listener: (context, state) {
          if (state.status == EditReportStatus.failure && state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_mapFailureMessage(state.failure!, l10n)),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedDate = state.selectedDate ?? widget.report.itemDate;
          final formattedDate =
              DateFormat.yMMMd(locale).format(selectedDate);

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsetsDirectional.all(16.r),
              children: [
                if (state.failure != null) ...[
                  ErrorBanner(
                    title: _mapFailureTitle(state.failure!, l10n),
                    message: _mapFailureMessage(state.failure!, l10n),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Type selector
                Text(
                  l10n.reportTypeLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'lost',
                      label: Text(l10n.typeLost),
                    ),
                    ButtonSegment(
                      value: 'found',
                      label: Text(l10n.typeFound),
                    ),
                  ],
                  selected: {state.selectedType},
                  onSelectionChanged: (newSelection) {
                    context
                        .read<EditReportCubit>()
                        .typeChanged(newSelection.first);
                  },
                ),
                SizedBox(height: 16.h),

                // Title
                AppTextField(
                  label: l10n.reportTitleLabel,
                  controller: _titleController,
                  hint: l10n.reportTitleHint,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.length < AppLimits.reportTitleMinLength) {
                      return l10n.titleTooShort;
                    }
                    if (text.length > AppLimits.reportTitleMaxLength) {
                      return l10n.titleTooLong;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Category Dropdown
                Text(
                  l10n.categoryLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: state.selectedCategoryId,
                  hint: Text(l10n.selectCategory),
                  items: state.categories.map((cat) {
                    final name = cat.localizedName(locale);
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      context.read<EditReportCubit>().categoryChanged(id);
                    }
                  },
                  validator: (value) =>
                      value == null ? l10n.fieldRequired : null,
                ),
                SizedBox(height: 16.h),

                // Area Dropdown
                Text(
                  l10n.areaLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  initialValue: state.selectedAreaId,
                  hint: Text(l10n.selectArea),
                  items: state.areas.map((area) {
                    final name = area.localizedName(locale);
                    return DropdownMenuItem(
                      value: area.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      context.read<EditReportCubit>().areaChanged(id);
                    }
                  },
                  validator: (value) =>
                      value == null ? l10n.fieldRequired : null,
                ),
                SizedBox(height: 16.h),

                // Date Picker field
                Text(
                  l10n.itemDateLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _pickDate(selectedDate),
                  borderRadius: BorderRadius.circular(14.r),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Description
                AppTextField(
                  label: l10n.descriptionLabel,
                  controller: _descriptionController,
                  hint: l10n.descriptionHint,
                  maxLines: 4,
                  minLines: 4,
                  maxLength: 1000,
                ),
                SizedBox(height: 24.h),

                // Save button
                AppButton(
                  label: l10n.saveChanges,
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
