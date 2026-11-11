part of 'create_report_cubit.dart';

@immutable
sealed class CreateReportState {}

final class CreateReportInitial extends CreateReportState {}

final class CreateReportFormUpdated extends CreateReportState {
  final bool isLost;
  final String title;
  final String? category;
  final String? district;
  final DateTime date;
  final List<XFile> photos;
  final Set<int> rejectedPhotoIndices;
  final Map<String, String?> errors;

  CreateReportFormUpdated({
    required this.isLost,
    required this.title,
    this.category,
    this.district,
    required this.date,
    required this.photos,
    required this.rejectedPhotoIndices,
    required this.errors,
  });

  CreateReportFormUpdated copyWith({
    bool? isLost,
    String? title,
    String? category,
    String? district,
    DateTime? date,
    List<XFile>? photos,
    Set<int>? rejectedPhotoIndices,
    Map<String, String?>? errors,
  }) {
    return CreateReportFormUpdated(
      isLost: isLost ?? this.isLost,
      title: title ?? this.title,
      category: category ?? this.category,
      district: district ?? this.district,
      date: date ?? this.date,
      photos: photos ?? this.photos,
      rejectedPhotoIndices: rejectedPhotoIndices ?? this.rejectedPhotoIndices,
      errors: errors ?? this.errors,
    );
  }
}

final class CreateReportSubmitting extends CreateReportState {}

final class CreateReportSuccess extends CreateReportState {
  final String referenceId;
  CreateReportSuccess({required this.referenceId});
}

final class CreateReportFailure extends CreateReportState {
  final String message;
  CreateReportFailure({required this.message});
}
