import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/area_entity.dart';
import 'package:found_it/features/reports/domain/entities/category_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_failure.dart';
import 'package:found_it/features/reports/domain/entities/report_field_error.dart';
import 'package:found_it/features/reports/domain/entities/report_image.dart';

sealed class CreateReportState extends Equatable {
  const CreateReportState();

  @override
  List<Object?> get props => [];
}

class CreateReportInitial extends CreateReportState {
  const CreateReportInitial();
}

class CreateReportFormState extends CreateReportState {
  final bool isLost;
  final String title;
  final String? categoryId;
  final String? areaId;
  final String? cityId;
  final DateTime date;
  final List<ReportImage> photos;
  final Set<int> rejectedPhotoIndices;
  final Map<String, ReportFieldError> errors;
  final List<CategoryEntity> categories;
  final List<AreaEntity> areas;
  final bool isLoadingData;
  final bool isSubmitting;
  final ReportFailureType? submitFailure;
  final ReportFailureType? initialDataFailure;
  final bool hasInvalidFile;

  const CreateReportFormState({
    required this.isLost,
    required this.title,
    this.categoryId,
    this.areaId,
    this.cityId,
    required this.date,
    required this.photos,
    required this.rejectedPhotoIndices,
    required this.errors,
    this.categories = const [],
    this.areas = const [],
    this.isLoadingData = false,
    this.isSubmitting = false,
    this.submitFailure,
    this.initialDataFailure,
    this.hasInvalidFile = false,
  });

  CreateReportFormState copyWith({
    bool? isLost,
    String? title,
    String? categoryId,
    bool clearCategory = false,
    String? areaId,
    bool clearArea = false,
    String? cityId,
    DateTime? date,
    List<ReportImage>? photos,
    Set<int>? rejectedPhotoIndices,
    Map<String, ReportFieldError>? errors,
    List<CategoryEntity>? categories,
    List<AreaEntity>? areas,
    bool? isLoadingData,
    bool? isSubmitting,
    ReportFailureType? submitFailure,
    bool clearSubmitFailure = false,
    ReportFailureType? initialDataFailure,
    bool clearInitialDataFailure = false,
    bool? hasInvalidFile,
  }) {
    return CreateReportFormState(
      isLost: isLost ?? this.isLost,
      title: title ?? this.title,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      areaId: clearArea ? null : (areaId ?? this.areaId),
      cityId: cityId ?? this.cityId,
      date: date ?? this.date,
      photos: photos ?? this.photos,
      rejectedPhotoIndices: rejectedPhotoIndices ?? this.rejectedPhotoIndices,
      errors: errors ?? this.errors,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitFailure: clearSubmitFailure
          ? null
          : (submitFailure ?? this.submitFailure),
      initialDataFailure: clearInitialDataFailure
          ? null
          : (initialDataFailure ?? this.initialDataFailure),
      hasInvalidFile: hasInvalidFile ?? this.hasInvalidFile,
    );
  }

  @override
  List<Object?> get props => [
        isLost,
        title,
        categoryId,
        areaId,
        cityId,
        date,
        photos,
        rejectedPhotoIndices,
        errors,
        categories,
        areas,
        isLoadingData,
        isSubmitting,
        submitFailure,
        initialDataFailure,
        hasInvalidFile,
      ];
}

class CreateReportSuccess extends CreateReportState {
  final String referenceId;

  const CreateReportSuccess(this.referenceId);

  @override
  List<Object?> get props => [referenceId];
}
