import 'package:found_it/core/models/report_status.dart';
import 'package:found_it/core/models/report_type.dart';
import 'package:found_it/features/explore/domain/report_entity.dart';

/// One row of the `report_details` view returned by `search_reports`.
class ReportModel extends ReportEntity {
  const ReportModel({
    required super.id,
    required super.refCode,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.type,
    required super.status,
    required super.categoryNameEn,
    required super.categoryNameAr,
    required super.cityNameEn,
    required super.cityNameAr,
    required super.areaNameEn,
    required super.areaNameAr,
    required super.itemDate,
    required super.images,
    required super.isMine,
    required this.userId,
    required this.categoryIcon,
    required this.cityId,
    required this.areaId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String userId;
  final String categoryIcon;
  final String cityId;
  final String areaId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      refCode: json['ref_code'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      categoryId: json['category_id'] as String? ?? '',
      categoryNameEn: json['category_name_en'] as String? ?? '',
      categoryNameAr: json['category_name_ar'] as String? ?? '',
      categoryIcon: json['category_icon'] as String? ?? '',
      cityId: json['city_id'] as String? ?? '',
      cityNameEn: json['city_name_en'] as String? ?? '',
      cityNameAr: json['city_name_ar'] as String? ?? '',
      areaId: json['area_id'] as String? ?? '',
      areaNameEn: json['area_name_en'] as String? ?? '',
      areaNameAr: json['area_name_ar'] as String? ?? '',
      type: ReportType.fromDb(json['type'] as String? ?? 'lost'),
      status: ReportStatus.fromDb(json['status'] as String? ?? 'active'),
      itemDate: _parseDate(json['item_date']) ?? DateTime.now(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((image) => image.toString())
              .toList() ??
          const [],
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
      deletedAt: _parseDate(json['deleted_at']),
      isMine: json['is_mine'] == true,
    );
  }

  /// Maps the database row to the entity the presentation layer uses.
  ReportEntity toEntity() => ReportEntity(
    id: id,
    refCode: refCode,
    title: title,
    description: description,
    categoryId: categoryId,
    type: type,
    status: status,
    categoryNameEn: categoryNameEn,
    categoryNameAr: categoryNameAr,
    cityNameEn: cityNameEn,
    cityNameAr: cityNameAr,
    areaNameEn: areaNameEn,
    areaNameAr: areaNameAr,
    itemDate: itemDate,
    images: images,
    isMine: isMine,
  );

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
