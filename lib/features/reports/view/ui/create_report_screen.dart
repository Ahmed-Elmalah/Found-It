import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/constants/app_limits.dart';
import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/core/widgets/app_button.dart';
import 'package:found_it/core/widgets/app_text_field.dart';
import 'package:found_it/core/widgets/error_banner.dart';
import 'package:found_it/features/reports/domain/entities/report_field_error.dart';
import 'package:found_it/features/reports/view/cubit/create_report_cubit.dart';
import 'package:found_it/features/reports/view/cubit/create_report_state.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final lang = Localizations.localeOf(context).languageCode;
        context.read<CreateReportCubit>().loadInitialData(lang: lang);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onClose() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  String? _mapTitleError(ReportFieldError? error, AppLocalizations l10n) {
    if (error == null) return null;
    switch (error) {
      case ReportFieldError.required:
        return l10n.fieldRequired;
      case ReportFieldError.tooShort:
        return l10n.titleTooShort;
      case ReportFieldError.tooLong:
        return l10n.titleTooLong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<CreateReportCubit, CreateReportState>(
      listener: (context, state) {
        if (state is CreateReportSuccess) {
          context.go(AppRoutes.reportCreated, extra: state.referenceId);
        } else if (state is CreateReportFormState &&
            state.submitError != null &&
            state.submitError!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.submitError!),
              backgroundColor: colors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CreateReportCubit>();

        final form = state is CreateReportFormState
            ? state
            : CreateReportFormState(
                isLost: true,
                title: '',
                date: DateTime.now(),
                photos: const [],
                rejectedPhotoIndices: const {},
                errors: const {},
              );

        final isSubmitting = form.isSubmitting;
        final errors = form.errors;

        if (_titleController.text != form.title) {
          _titleController.value = _titleController.value.copyWith(
            text: form.title,
            selection: TextSelection.collapsed(offset: form.title.length),
          );
        }

        final hasRejectedPhotos =
            form.hasInvalidFile || form.rejectedPhotoIndices.isNotEmpty;
        final hasValidationErrors = errors.isNotEmpty;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _onClose,
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
                  // ── Top Error Banner (Fixed at top below AppBar - P25 & P26) ──
                  if (hasRejectedPhotos)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        8.h,
                        16.w,
                        4.h,
                      ),
                      child: ErrorBanner(
                        title: l10n.invalidFileBannerTitle,
                        message: l10n.invalidFileBannerMessage,
                      ),
                    )
                  else if (hasValidationErrors)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        8.h,
                        16.w,
                        4.h,
                      ),
                      child: ErrorBanner(
                        title: l10n.requiredFieldsBannerTitle,
                        message: l10n.requiredFieldsBannerMessage,
                      ),
                    ),

                  // ── Scrollable form ─────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        8.h,
                        16.w,
                        40.h,
                      ),
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
                          AppTextField(
                            label: l10n.itemTitle,
                            hint: l10n.itemTitleHint,
                            controller: _titleController,
                            isRequired: true,
                            maxLength: AppLimits.reportTitleMaxLength,
                            showErrorIcon: true,
                            errorText: _mapTitleError(errors['title'], l10n),
                            onChanged: cubit.updateTitle,
                          ),
                          SizedBox(height: 16.h),

                          // ── Category ────────────────────────────────────────
                          CategorySelectorField(
                            categories: form.categories,
                            selectedId: form.categoryId,
                            errorText: errors.containsKey('category')
                                ? l10n.categoryRequired
                                : null,
                            onSelected: cubit.selectCategory,
                          ),
                          SizedBox(height: 16.h),

                          // ── District / Area ─────────────────────────────────
                          DistrictSelectorField(
                            areas: form.areas,
                            selectedId: form.areaId,
                            errorText: errors.containsKey('district')
                                ? l10n.districtRequired
                                : null,
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
                            errorText: errors.containsKey('photos')
                                ? l10n.photosRequired
                                : null,
                            onAddPhoto: cubit.pickPhoto,
                            onRemovePhoto: cubit.removePhoto,
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),

                  // ── Sticky submit button ────────────────────────────────────
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        16.w,
                        12.h,
                        16.w,
                        12.h,
                      ),
                      child: AppButton(
                        label: l10n.submitReport,
                        isLoading: isSubmitting,
                        onPressed: cubit.submit,
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
