import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/report_image.dart';

class CreateReportParams extends Equatable {
  final String type; // 'lost' | 'found'
  final String title;
  final String categoryId;
  final String cityId;
  final String areaId;
  final List<ReportImage> images;
  final DateTime itemDate;
  final String? description;
  final String? privateDetails;
  final List<Map<String, dynamic>>? questions;

  const CreateReportParams({
    required this.type,
    required this.title,
    required this.categoryId,
    required this.cityId,
    required this.areaId,
    required this.images,
    required this.itemDate,
    this.description,
    this.privateDetails,
    this.questions,
  });

  @override
  List<Object?> get props => [
        type,
        title,
        categoryId,
        cityId,
        areaId,
        images,
        itemDate,
        description,
        privateDetails,
        questions,
      ];
}
