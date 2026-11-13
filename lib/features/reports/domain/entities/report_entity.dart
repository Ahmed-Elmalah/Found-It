import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  const ReportEntity({
    required this.id,
    required this.refCode,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.categoryId,
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryIcon,
    required this.cityId,
    this.cityNameEn,
    this.cityNameAr,
    required this.areaId,
    this.areaNameEn,
    this.areaNameAr,
    required this.itemDate,
    required this.images,
    required this.status,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isMine = false,
  });

  final String id;
  final String refCode;
  final String userId;
  final String type; // 'lost' | 'found'
  final String title;
  final String? description;
  final String categoryId;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? categoryIcon;
  final String cityId;
  final String? cityNameEn;
  final String? cityNameAr;
  final String areaId;
  final String? areaNameEn;
  final String? areaNameAr;
  final DateTime itemDate;
  final List<String> images;
  final String status; // 'active' | 'matching' | 'recovered'
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMine;

  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  bool get isActive => status == 'active';
  bool get isMatching => status == 'matching';
  bool get isRecovered => status == 'recovered';

  String localizedCategory(String languageCode) =>
      languageCode == 'ar' ? (categoryNameAr ?? '') : (categoryNameEn ?? '');

  String localizedCity(String languageCode) =>
      languageCode == 'ar' ? (cityNameAr ?? '') : (cityNameEn ?? '');

  String localizedArea(String languageCode) =>
      languageCode == 'ar' ? (areaNameAr ?? '') : (areaNameEn ?? '');

  @override
  List<Object?> get props => [
        id,
        refCode,
        userId,
        type,
        title,
        description,
        categoryId,
        categoryNameEn,
        categoryNameAr,
        categoryIcon,
        cityId,
        cityNameEn,
        cityNameAr,
        areaId,
        areaNameEn,
        areaNameAr,
        itemDate,
        images,
        status,
        deletedAt,
        createdAt,
        updatedAt,
        isMine,
      ];
}
