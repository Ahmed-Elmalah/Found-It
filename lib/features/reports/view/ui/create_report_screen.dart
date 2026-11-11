import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/ui/report_created_screen.dart';
import 'package:found_it/features/reports/view/ui/widgets/category_selector_field.dart';
import 'package:found_it/features/reports/view/ui/widgets/date_picker_field.dart';
import 'package:found_it/features/reports/view/ui/widgets/district_selector_field.dart';
import 'package:found_it/features/reports/view/ui/widgets/photo_uploader_widget.dart';
import 'package:found_it/features/reports/view/ui/widgets/report_type_toggle.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<CreateReportCubit, CreateReportState>(
      listener: (context, state) {
        if (state is CreateReportSuccess) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  ReportCreatedScreen(referenceId: state.referenceId),
            ),
          );
        } else if (state is CreateReportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateReportCubit>();

        // Extract form data from state
        final form = state is CreateReportFormUpdated
            ? state
            : CreateReportFormUpdated(
                isLost: true,
                title: '',
                date: DateTime.now(),
                photos: [],
                rejectedPhotoIndices: {},
                errors: {},
              );

        final isSubmitting = state is CreateReportSubmitting;
        final errors = form.errors;

        // Sync title controller without resetting cursor
        if (_titleController.text != form.title) {
          _titleController.value = _titleController.value.copyWith(
            text: form.title,
            selection: TextSelection.collapsed(offset: form.title.length),
          );
        }

        final hasRejectedPhotos = form.rejectedPhotoIndices.isNotEmpty;
        final hasValidationErrors = errors.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            titleSpacing: 0,
            title: Text(
              l10n.createReport,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: colors.onSurface,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // ── Top Error Banner (Fixed at top below AppBar - P25 & P26 in Figma) ──
                  if (hasRejectedPhotos || hasValidationErrors)
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: colors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: colors.error.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 18.r,
                              color: colors.error,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                hasRejectedPhotos
                                    ? l10n.invalidFileBanner
                                    : l10n.requiredFieldsBanner,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colors.error,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Scrollable form ─────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.w, 8.h, 16.w, 40.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Report type toggle ──────────────────────────────
                          ReportTypeToggle(
                            isLost: form.isLost,
                            onChanged: cubit.toggleReportType,
                          ),
                          SizedBox(height: 20.h),

                          // ── Item title ──────────────────────────────────────
                          _TitleField(
                            controller: _titleController,
                            errorText: errors['title'],
                            onChanged: cubit.updateTitle,
                          ),
                          SizedBox(height: 16.h),

                          // ── Category ────────────────────────────────────────
                          CategorySelectorField(
                            selectedValue: form.category,
                            errorText: errors['category'],
                            onSelected: cubit.selectCategory,
                          ),
                          SizedBox(height: 16.h),

                          // ── District ────────────────────────────────────────
                          DistrictSelectorField(
                            selectedValue: form.district,
                            errorText: errors['district'],
                            onSelected: cubit.selectDistrict,
                          ),
                          SizedBox(height: 16.h),

                          // ── Date ────────────────────────────────────────────
                          DatePickerField(
                            selectedDate: form.date,
                            onDateSelected: cubit.selectDate,
                          ),
                          SizedBox(height: 20.h),

                          // ── Photos ──────────────────────────────────────────
                          PhotoUploaderWidget(
                            photos: form.photos,
                            rejectedIndices: form.rejectedPhotoIndices,
                            errorText: errors['photos'],
                            onAddPhoto: (source) => cubit.pickPhoto(source),
                            onRemovePhoto: cubit.removePhoto,
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Sticky submit button (Centered and responsive) ──────────
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () => cubit.validateAndSubmit(
                                    titleTooShort: l10n.titleTooShort,
                                    titleTooLong: l10n.titleTooLong,
                                    categoryRequired: l10n.categoryRequired,
                                    districtRequired: l10n.districtRequired,
                                    photosRequired: l10n.photosRequired,
                                  ),
                          child: isSubmitting
                              ? SizedBox(
                                  height: 20.r,
                                  width: 20.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.r,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Text(
                                  l10n.submitReport,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Title field widget ──────────────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _TitleField({
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final charCount = controller.text.length;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.itemTitle,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: hasError ? colors.error : colors.onSurface,
              ),
            ),
            Text(
              l10n.itemTitleCounter(charCount),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: 50,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
              null,
          style: TextStyle(
            fontSize: 15.sp,
            color: colors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: l10n.itemTitleHint,
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 14.r, color: colors.error),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  errorText!,
                  style: TextStyle(fontSize: 12.sp, color: colors.error),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
