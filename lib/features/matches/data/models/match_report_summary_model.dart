import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';

class MatchReportSummaryModel extends MatchReportSummary {
  const MatchReportSummaryModel({
    required super.id,
    required super.refCode,
    required super.type,
    required super.title,
    super.description,
    super.image,
    super.images,
    required super.categoryNameEn,
    required super.categoryNameAr,
    required super.cityNameEn,
    required super.cityNameAr,
    required super.areaNameEn,
    required super.areaNameAr,
    required super.itemDate,
    required super.status,
    super.isDeleted,
  });

  factory MatchReportSummaryModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    final rawDate = json['item_date'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String && rawDate.isNotEmpty) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawImages = json['images'];
    final imagesList = (rawImages is List)
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];

    return MatchReportSummaryModel(
      id: json['id'] as String? ?? '',
      refCode: json['ref_code'] as String? ?? '',
      type: json['type'] as String? ?? 'lost',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      image: json['image'] as String?,
      images: imagesList,
      categoryNameEn: json['category_name_en'] as String? ?? '',
      categoryNameAr: json['category_name_ar'] as String? ?? '',
      cityNameEn: json['city_name_en'] as String? ?? '',
      cityNameAr: json['city_name_ar'] as String? ?? '',
      areaNameEn: json['area_name_en'] as String? ?? '',
      areaNameAr: json['area_name_ar'] as String? ?? '',
      itemDate: parsedDate,
      status: json['status'] as String? ?? 'matching',
      isDeleted: json['is_deleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ref_code': refCode,
        'type': type,
        'title': title,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
        'images': images,
        'category_name_en': categoryNameEn,
        'category_name_ar': categoryNameAr,
        'city_name_en': cityNameEn,
        'city_name_ar': cityNameAr,
        'area_name_en': areaNameEn,
        'area_name_ar': areaNameAr,
        'item_date': itemDate.toIso8601String().split('T').first,
        'status': status,
        'is_deleted': isDeleted,
      };
}
