import 'package:equatable/equatable.dart';

class MatchReportSummary extends Equatable {
  final String id;
  final String refCode;
  final String type; // 'lost' | 'found'
  final String title;
  final String? description;
  final String? image;
  final List<String> images;
  final String categoryNameEn;
  final String categoryNameAr;
  final String cityNameEn;
  final String cityNameAr;
  final String areaNameEn;
  final String areaNameAr;
  final DateTime itemDate;
  final String status;
  final bool isDeleted;

  const MatchReportSummary({
    required this.id,
    required this.refCode,
    required this.type,
    required this.title,
    this.description,
    this.image,
    this.images = const [],
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.cityNameEn,
    required this.cityNameAr,
    required this.areaNameEn,
    required this.areaNameAr,
    required this.itemDate,
    required this.status,
    this.isDeleted = false,
  });

  String localizedCategory(String locale) =>
      locale.startsWith('ar') ? categoryNameAr : categoryNameEn;

  String localizedCity(String locale) =>
      locale.startsWith('ar') ? cityNameAr : cityNameEn;

  String localizedArea(String locale) =>
      locale.startsWith('ar') ? areaNameAr : areaNameEn;

  String categoryName(String locale) => localizedCategory(locale);

  String cityName(String locale) => localizedCity(locale);

  String areaName(String locale) => localizedArea(locale);

  @override
  List<Object?> get props => [
        id,
        refCode,
        type,
        title,
        description,
        image,
        images,
        categoryNameEn,
        categoryNameAr,
        cityNameEn,
        cityNameAr,
        areaNameEn,
        areaNameAr,
        itemDate,
        status,
        isDeleted,
      ];
}
