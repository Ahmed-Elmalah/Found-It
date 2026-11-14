import 'package:equatable/equatable.dart';

/// A lightweight domain entity representing a report card in the Home feed.
class HomeReportItem extends Equatable {
  const HomeReportItem({
    required this.id,
    required this.refCode,
    required this.title,
    this.description,
    required this.type,
    required this.categoryName,
    required this.categoryIcon,
    required this.areaName,
    required this.cityName,
    this.categoryNameEn,
    this.categoryNameAr,
    this.areaNameEn,
    this.areaNameAr,
    this.cityNameEn,
    this.cityNameAr,
    this.cityId,
    this.areaId,
    this.categoryId,
    required this.itemDate,
    required this.images,
    required this.status,
    required this.isMine,
    required this.createdAt,
  });

  final String id;
  final String refCode;
  final String title;
  final String? description;
  final String type; // 'lost' | 'found'
  final String categoryName;
  final String categoryIcon;
  final String areaName;
  final String cityName;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? areaNameEn;
  final String? areaNameAr;
  final String? cityNameEn;
  final String? cityNameAr;
  final String? cityId;
  final String? areaId;
  final String? categoryId;
  final DateTime itemDate;
  final List<String> images;
  final String status;
  final bool isMine;
  final DateTime createdAt;

  bool get isLost => type.toLowerCase() == 'lost';
  bool get isFound => type.toLowerCase() == 'found';
  bool get hasImages => images.isNotEmpty;

  String localizedCategory(String locale) =>
      locale == 'ar' ? (categoryNameAr ?? categoryName) : (categoryNameEn ?? categoryName);

  String localizedCity(String locale) =>
      locale == 'ar' ? (cityNameAr ?? cityName) : (cityNameEn ?? cityName);

  String localizedArea(String locale) =>
      locale == 'ar' ? (areaNameAr ?? areaName) : (areaNameEn ?? areaName);

  @override
  List<Object?> get props => [
        id,
        refCode,
        title,
        description,
        type,
        categoryName,
        categoryIcon,
        areaName,
        cityName,
        categoryNameEn,
        categoryNameAr,
        areaNameEn,
        areaNameAr,
        cityNameEn,
        cityNameAr,
        cityId,
        areaId,
        categoryId,
        itemDate,
        images,
        status,
        isMine,
        createdAt,
      ];
}
