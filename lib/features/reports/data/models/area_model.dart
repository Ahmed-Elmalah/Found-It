import 'package:found_it/features/reports/domain/entities/area_entity.dart';

class AreaModel extends AreaEntity {
  const AreaModel({
    required super.id,
    required super.cityId,
    required super.nameEn,
    required super.nameAr,
    super.isActive = true,
    super.sortOrder = 0,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String,
      cityId: json['city_id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
