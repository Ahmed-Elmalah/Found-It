import 'package:found_it/features/reports/domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.refCode,
    required super.userId,
    required super.type,
    required super.title,
    super.description,
    required super.categoryId,
    super.categoryNameEn,
    super.categoryNameAr,
    super.categoryIcon,
    required super.cityId,
    super.cityNameEn,
    super.cityNameAr,
    required super.areaId,
    super.areaNameEn,
    super.areaNameAr,
    required super.itemDate,
    required super.images,
    required super.status,
    super.deletedAt,
    required super.createdAt,
    required super.updatedAt,
    super.isMine = false,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      refCode: json['ref_code'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      type: json['type'] as String? ?? 'lost',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      categoryNameEn: json['category_name_en'] as String?,
      categoryNameAr: json['category_name_ar'] as String?,
      categoryIcon: json['category_icon'] as String?,
      cityId: json['city_id'] as String? ?? '',
      cityNameEn: json['city_name_en'] as String?,
      cityNameAr: json['city_name_ar'] as String?,
      areaId: json['area_id'] as String? ?? '',
      areaNameEn: json['area_name_en'] as String?,
      areaNameAr: json['area_name_ar'] as String?,
      itemDate: json['item_date'] != null
          ? DateTime.tryParse(json['item_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'active',
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isMine: json['is_mine'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref_code': refCode,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'city_id': cityId,
      'area_id': areaId,
      'item_date': itemDate.toIso8601String().split('T').first,
      'images': images,
      'status': status,
    };
  }
}
