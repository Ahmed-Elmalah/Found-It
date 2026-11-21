import 'package:found_it/features/chat/domain/entities/chat_report_summary_entity.dart';

class ChatReportSummaryModel extends ChatReportSummaryEntity {
  const ChatReportSummaryModel({
    required super.id,
    required super.refCode,
    required super.type,
    required super.title,
    super.description,
    super.image,
    super.images,
    super.categoryNameEn,
    super.categoryNameAr,
    super.cityNameEn,
    super.cityNameAr,
    super.areaNameEn,
    super.areaNameAr,
    super.itemDate,
    super.status,
    super.isDeleted,
  });

  factory ChatReportSummaryModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = const [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      parsedImages = [json['image'].toString()];
    }

    DateTime? parsedDate;
    if (json['item_date'] != null) {
      parsedDate = DateTime.tryParse(json['item_date'].toString());
    }

    return ChatReportSummaryModel(
      id: json['id']?.toString() ?? '',
      refCode: json['ref_code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'lost',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      images: parsedImages,
      categoryNameEn: json['category_name_en']?.toString(),
      categoryNameAr: json['category_name_ar']?.toString(),
      cityNameEn: json['city_name_en']?.toString(),
      cityNameAr: json['city_name_ar']?.toString(),
      areaNameEn: json['area_name_en']?.toString(),
      areaNameAr: json['area_name_ar']?.toString(),
      itemDate: parsedDate,
      status: json['status']?.toString(),
      isDeleted: json['is_deleted'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ref_code': refCode,
        'type': type,
        'title': title,
        'description': description,
        'image': image,
        'images': images,
        'category_name_en': categoryNameEn,
        'category_name_ar': categoryNameAr,
        'city_name_en': cityNameEn,
        'city_name_ar': cityNameAr,
        'area_name_en': areaNameEn,
        'area_name_ar': areaNameAr,
        'item_date': itemDate?.toIso8601String(),
        'status': status,
        'is_deleted': isDeleted,
      };
}
