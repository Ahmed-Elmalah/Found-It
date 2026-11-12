import 'package:found_it/features/city/domain/city_entity.dart';

class CityModel extends CityEntity {
  const CityModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    super.sortOrder = 0,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as String,
    nameEn: (json['name_en'] as String?) ?? '',
    nameAr: (json['name_ar'] as String?) ?? '',
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name_en': nameEn,
    'name_ar': nameAr,
    'sort_order': sortOrder,
  };
}
