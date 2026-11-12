import 'package:equatable/equatable.dart';

import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';

/// A report as returned by `search_reports` (a `report_details` row).
class ReportEntity extends Equatable {
  const ReportEntity({
    required this.id,
    required this.refCode,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.status,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.cityNameEn,
    required this.cityNameAr,
    required this.areaNameEn,
    required this.areaNameAr,
    required this.itemDate,
    required this.images,
    required this.isMine,
  });

  final String id;
  final String refCode;
  final String title;

  /// Optional details written by the owner (max 1000 characters).
  final String? description;

  /// The `categories.id` of the report.
  final String categoryId;

  final ReportType type;
  final ReportStatus status;

  final String categoryNameEn;
  final String categoryNameAr;
  final String cityNameEn;
  final String cityNameAr;
  final String areaNameEn;
  final String areaNameAr;

  /// The day the item was lost / found.
  final DateTime itemDate;

  /// Public photo URLs (1 to 4).
  final List<String> images;

  /// True when the logged-in user owns the report.
  final bool isMine;

  /// First photo, or `null` when the report has none.
  String? get primaryImageUrl => images.isEmpty ? null : images.first;

  /// "Area, City" in the app language, e.g. "Zamalek, Cairo".
  String location(String languageCode) {
    final area = languageCode == 'ar' ? areaNameAr : areaNameEn;
    final city = languageCode == 'ar' ? cityNameAr : cityNameEn;
    if (area.isEmpty) return city;
    if (city.isEmpty) return area;
    return '$area, $city';
  }

  /// The category name in the app language.
  String categoryName(String languageCode) =>
      languageCode == 'ar' ? categoryNameAr : categoryNameEn;

  @override
  List<Object?> get props => [
    id,
    refCode,
    title,
    description,
    categoryId,
    type,
    status,
    categoryNameEn,
    categoryNameAr,
    cityNameEn,
    cityNameAr,
    areaNameEn,
    areaNameAr,
    itemDate,
    images,
    isMine,
  ];
}
