import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:found_it/core/constants/app_limits.dart';

part 'create_report_state.dart';

class CreateReportCubit extends Cubit<CreateReportState> {
  CreateReportCubit() : super(CreateReportInitial());

  final ImagePicker _picker = ImagePicker();

  // ── Helpers ────────────────────────────────────────────────────────────────

  CreateReportFormUpdated get _currentForm {
    final s = state;
    if (s is CreateReportFormUpdated) return s;
    return CreateReportFormUpdated(
      isLost: true,
      title: '',
      date: DateTime.now(),
      photos: [],
      rejectedPhotoIndices: {},
      errors: {},
    );
  }

  // ── Form field updates ──────────────────────────────────────────────────────

  void toggleReportType(bool isLost) {
    emit(_currentForm.copyWith(isLost: isLost, errors: {}));
  }

  void updateTitle(String value) {
    final form = _currentForm;
    final errors = Map<String, String?>.from(form.errors)..remove('title');
    emit(form.copyWith(title: value, errors: errors));
  }

  void selectCategory(String value) {
    final form = _currentForm;
    final errors = Map<String, String?>.from(form.errors)..remove('category');
    emit(form.copyWith(category: value, errors: errors));
  }

  void selectDistrict(String value) {
    final form = _currentForm;
    final errors = Map<String, String?>.from(form.errors)..remove('district');
    emit(form.copyWith(district: value, errors: errors));
  }

  void selectDate(DateTime value) {
    emit(_currentForm.copyWith(date: value));
  }

  // ── Photo handling ──────────────────────────────────────────────────────────

  Future<void> pickPhoto(ImageSource source) async {
    if (_currentForm.photos.length >= AppLimits.reportMaxImages) return;

    try {
      XFile? picked;
      try {
        picked = await _picker.pickImage(source: source);
      } catch (e) {
        // If camera is unsupported (e.g. on Windows Desktop or Simulator), fallback to gallery
        if (source == ImageSource.camera) {
          picked = await _picker.pickImage(source: ImageSource.gallery);
        } else {
          rethrow;
        }
      }

      if (picked == null) return;

      final String name = picked.name.isNotEmpty ? picked.name : picked.path;
      final String ext = name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
      final int bytes = await picked.length();

      final bool validType = AppLimits.allowedImageExtensions.contains(ext) ||
          ext == 'jpg' ||
          ext == 'jpeg' ||
          ext == 'png' ||
          ext == 'webp';
      final bool validSize = bytes <= AppLimits.maxImageSizeBytes;

      final form = _currentForm;
      if (!validType || !validSize) {
        final updatedPhotos = List<XFile>.from(form.photos)..add(picked);
        final rejectedIdx = Set<int>.from(form.rejectedPhotoIndices)
          ..add(updatedPhotos.length - 1);
        emit(form.copyWith(
          photos: updatedPhotos,
          rejectedPhotoIndices: rejectedIdx,
        ));
      } else {
        final updatedPhotos = List<XFile>.from(form.photos)..add(picked);
        final errors = Map<String, String?>.from(form.errors)..remove('photos');
        emit(form.copyWith(
          photos: updatedPhotos,
          errors: errors,
        ));
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  void removePhoto(int index) {
    final form = _currentForm;
    final updatedPhotos = List<XFile>.from(form.photos)..removeAt(index);

    // Re-map rejected indices after removal
    final updatedRejected = form.rejectedPhotoIndices
        .where((i) => i != index)
        .map((i) => i > index ? i - 1 : i)
        .toSet();

    final errors = Map<String, String?>.from(form.errors)..remove('photos');
    emit(form.copyWith(
      photos: updatedPhotos,
      rejectedPhotoIndices: updatedRejected,
      errors: errors,
    ));
  }

  // ── Validation ──────────────────────────────────────────────────────────────

  /// Validates the form and emits [CreateReportSubmitting] if valid.
  /// The actual Supabase submit will be wired by the backend teammate.
  void validateAndSubmit({
    required String titleTooShort,
    required String titleTooLong,
    required String categoryRequired,
    required String districtRequired,
    required String photosRequired,
  }) {
    final form = _currentForm;
    final errors = <String, String?>{};

    if (form.title.length < AppLimits.reportTitleMinLength) {
      errors['title'] = form.title.isEmpty ? titleTooShort : titleTooShort;
    } else if (form.title.length > AppLimits.reportTitleMaxLength) {
      errors['title'] = titleTooLong;
    }

    if (form.category == null) errors['category'] = categoryRequired;
    if (form.district == null) errors['district'] = districtRequired;

    final validPhotos = form.photos
        .asMap()
        .entries
        .where((e) => !form.rejectedPhotoIndices.contains(e.key))
        .toList();
    if (validPhotos.isEmpty) errors['photos'] = photosRequired;

    if (errors.isNotEmpty) {
      emit(form.copyWith(errors: errors));
      return;
    }

    // ── All valid — backend teammate wires the actual upload here ──────────
    emit(CreateReportSubmitting());
    // Temporary: emit success with placeholder ID so UI is testable
    emit(CreateReportSuccess(referenceId: '#RPT-0000'));
  }
}
