import 'package:found_it/features/explore/domain/area_entity.dart';

/// One row returned by `get_city_areas`.
class AreaModel extends AreaEntity {
  const AreaModel({
    required super.id,
    required super.cityId,
    required super.nameEn,
    required super.nameAr,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json['id'] as String,
      cityId: json['city_id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
    );
  }
}
