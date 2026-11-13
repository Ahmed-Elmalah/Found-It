import 'package:found_it/features/reports/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    super.icon = 'category',
    super.isActive = true,
    super.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      icon: (json['icon'] as String?) ?? 'category',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_en': nameEn,
        'name_ar': nameAr,
        'icon': icon,
      };
}
