import '../../domain/entities/home_report_item.dart';

class HomeReportModel extends HomeReportItem {
  const HomeReportModel({
    required super.id,
    required super.refCode,
    required super.title,
    super.description,
    required super.type,
    required super.categoryName,
    required super.categoryIcon,
    required super.areaName,
    required super.cityName,
    super.categoryNameEn,
    super.categoryNameAr,
    super.areaNameEn,
    super.areaNameAr,
    super.cityNameEn,
    super.cityNameAr,
    super.cityId,
    super.areaId,
    super.categoryId,
    required super.itemDate,
    required super.images,
    required super.status,
    required super.isMine,
    required super.createdAt,
  });

  factory HomeReportModel.fromJson(Map<String, dynamic> json) {
    final catEn = json['category_name_en'] as String? ?? 'General';
    final catAr = json['category_name_ar'] as String? ?? catEn;
    final cityEn = json['city_name_en'] as String? ?? '';
    final cityAr = json['city_name_ar'] as String? ?? cityEn;
    final areaEn = json['area_name_en'] as String? ?? '';
    final areaAr = json['area_name_ar'] as String? ?? areaEn;

    return HomeReportModel(
      id: json['id'] as String,
      refCode: json['ref_code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'found',
      categoryName: catAr,
      categoryNameEn: catEn,
      categoryNameAr: catAr,
      categoryIcon: json['category_icon'] as String? ?? 'inventory_2',
      cityName: cityAr,
      cityNameEn: cityEn,
      cityNameAr: cityAr,
      areaName: areaAr,
      areaNameEn: areaEn,
      areaNameAr: areaAr,
      cityId: json['city_id'] as String?,
      areaId: json['area_id'] as String?,
      categoryId: json['category_id'] as String?,
      itemDate: json['item_date'] != null
          ? DateTime.tryParse(json['item_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'active',
      isMine: json['is_mine'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref_code': refCode,
      'title': title,
      'description': description,
      'type': type,
      'category_name_en': categoryNameEn,
      'category_name_ar': categoryNameAr,
      'category_icon': categoryIcon,
      'city_name_en': cityNameEn,
      'city_name_ar': cityNameAr,
      'area_name_en': areaNameEn,
      'area_name_ar': areaNameAr,
      'city_id': cityId,
      'area_id': areaId,
      'category_id': categoryId,
      'item_date': itemDate.toIso8601String(),
      'images': images,
      'status': status,
      'is_mine': isMine,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
