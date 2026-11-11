import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/core/constants/app_limits.dart';
import 'package:found_it/features/reports/data/services/photo_picker_service.dart';
import 'package:found_it/features/reports/domain/entities/create_report_params.dart';
import 'package:found_it/features/reports/domain/entities/report_field_error.dart';
import 'package:found_it/features/reports/domain/repositories/reports_repository.dart';
import 'package:found_it/features/reports/domain/use_cases/create_report_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_categories_use_case.dart';
import 'package:found_it/features/reports/domain/use_cases/get_city_areas_use_case.dart';
import 'package:found_it/features/reports/view/cubit/create_report_state.dart';

class CreateReportCubit extends Cubit<CreateReportState> {
  final GetCategoriesUseCase getCategories;
  final GetCityAreasUseCase getCityAreas;
  final CreateReportUseCase createReport;
  final PhotoPickerService photoPicker;
  final ReportsRepository repository;

  CreateReportCubit({
    required this.getCategories,
    required this.getCityAreas,
    required this.createReport,
    required this.photoPicker,
    required this.repository,
  }) : super(const CreateReportInitial());

  CreateReportFormState get _currentForm {
    final s = state;
    if (s is CreateReportFormState) return s;
    return CreateReportFormState(
      isLost: true,
      title: '',
      date: DateTime.now(),
      photos: const [],
      rejectedPhotoIndices: const {},
      errors: const {},
    );
  }

  Future<void> loadInitialData({String lang = 'en'}) async {
    final form = _currentForm.copyWith(isLoadingData: true);
    emit(form);

    try {
      final cityId = await repository.getSelectedCityId();
      final categories = await getCategories();
      final areas = await getCityAreas(cityId: cityId, lang: lang);

      emit(_currentForm.copyWith(
        cityId: cityId,
        categories: categories,
        areas: areas,
        isLoadingData: false,
      ));
    } catch (e) {
      emit(_currentForm.copyWith(
        isLoadingData: false,
        submitError: e.toString(),
      ));
    }
  }

  void toggleReportType(bool isLost) {
    emit(_currentForm.copyWith(isLost: isLost));
  }

  void updateTitle(String value) {
    final form = _currentForm;
    final errors = Map<String, ReportFieldError>.from(form.errors)
      ..remove('title');
    emit(form.copyWith(title: value, errors: errors));
  }

  void selectCategory(String categoryId) {
    final form = _currentForm;
    final errors = Map<String, ReportFieldError>.from(form.errors)
      ..remove('category');
    emit(form.copyWith(categoryId: categoryId, errors: errors));
  }

  void selectDistrict(String areaId) {
    final form = _currentForm;
    final errors = Map<String, ReportFieldError>.from(form.errors)
      ..remove('district');
    emit(form.copyWith(areaId: areaId, errors: errors));
  }

  void selectDate(DateTime value) {
    emit(_currentForm.copyWith(date: value));
  }

  Future<void> pickPhoto(ImageSource source) async {
    final form = _currentForm;
    if (form.photos.length >= AppLimits.reportMaxImages) return;

    final picked = await photoPicker.pickImage(source: source);
    if (picked == null) return;

    final name = picked.name.isNotEmpty ? picked.name : picked.path;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    final bytes = await picked.length();

    // 2. Only JPG/PNG (AppLimits.allowedImageExtensions) — remove webp. Max AppLimits.maxImageSizeBytes.
    final validType = AppLimits.allowedImageExtensions.contains(ext);
    final validSize = bytes <= AppLimits.maxImageSizeBytes;

    final currentForm = _currentForm;
    final updatedPhotos = List<XFile>.from(currentForm.photos)..add(picked);

    if (!validType || !validSize) {
      final updatedRejected = Set<int>.from(currentForm.rejectedPhotoIndices)
        ..add(updatedPhotos.length - 1);
      emit(currentForm.copyWith(
        photos: updatedPhotos,
        rejectedPhotoIndices: updatedRejected,
        hasInvalidFile: true,
      ));
    } else {
      final updatedErrors =
          Map<String, ReportFieldError>.from(currentForm.errors)
            ..remove('photos');
      emit(currentForm.copyWith(
        photos: updatedPhotos,
        errors: updatedErrors,
      ));
    }
  }

  void removePhoto(int index) {
    final form = _currentForm;
    if (index < 0 || index >= form.photos.length) return;

    final updatedPhotos = List<XFile>.from(form.photos)..removeAt(index);
    final updatedRejected = form.rejectedPhotoIndices
        .where((i) => i != index)
        .map((i) => i > index ? i - 1 : i)
        .toSet();

    final updatedErrors = Map<String, ReportFieldError>.from(form.errors)
      ..remove('photos');

    emit(form.copyWith(
      photos: updatedPhotos,
      rejectedPhotoIndices: updatedRejected,
      hasInvalidFile: updatedRejected.isNotEmpty,
      errors: updatedErrors,
    ));
  }

  Future<void> submit() async {
    final form = _currentForm;
    final errors = <String, ReportFieldError>{};

    final trimmedTitle = form.title.trim();
    if (trimmedTitle.isEmpty) {
      errors['title'] = ReportFieldError.required;
    } else if (trimmedTitle.length < AppLimits.reportTitleMinLength) {
      errors['title'] = ReportFieldError.tooShort;
    } else if (trimmedTitle.length > AppLimits.reportTitleMaxLength) {
      errors['title'] = ReportFieldError.tooLong;
    }

    if (form.categoryId == null || form.categoryId!.isEmpty) {
      errors['category'] = ReportFieldError.required;
    }

    if (form.areaId == null || form.areaId!.isEmpty) {
      errors['district'] = ReportFieldError.required;
    }

    final validPhotos = form.photos
        .asMap()
        .entries
        .where((e) => !form.rejectedPhotoIndices.contains(e.key))
        .map((e) => e.value)
        .toList();

    if (validPhotos.isEmpty) {
      errors['photos'] = ReportFieldError.required;
    }

    if (errors.isNotEmpty || form.rejectedPhotoIndices.isNotEmpty) {
      emit(form.copyWith(
        title: trimmedTitle,
        errors: errors,
        hasInvalidFile: form.rejectedPhotoIndices.isNotEmpty,
      ));
      return;
    }

    emit(form.copyWith(
      title: trimmedTitle,
      errors: const {},
      isSubmitting: true,
      clearSubmitError: true,
    ));

    try {
      final cityId = form.cityId ?? await repository.getSelectedCityId();

      final refCode = await createReport(CreateReportParams(
        type: form.isLost ? 'lost' : 'found',
        title: trimmedTitle,
        categoryId: form.categoryId!,
        cityId: cityId,
        areaId: form.areaId!,
        images: validPhotos,
        itemDate: form.date,
      ));

      emit(CreateReportSuccess(refCode));
    } catch (e) {
      emit(_currentForm.copyWith(
        isSubmitting: false,
        submitError: e.toString(),
      ));
    }
  }
}
