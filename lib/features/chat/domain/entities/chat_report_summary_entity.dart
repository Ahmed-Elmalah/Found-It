import 'package:equatable/equatable.dart';

class ChatReportSummaryEntity extends Equatable {
  const ChatReportSummaryEntity({
    required this.id,
    required this.refCode,
    required this.type,
    required this.title,
    this.description,
    this.image,
    this.images = const [],
    this.categoryNameEn,
    this.categoryNameAr,
    this.cityNameEn,
    this.cityNameAr,
    this.areaNameEn,
    this.areaNameAr,
    this.itemDate,
    this.status,
    this.isDeleted = false,
  });

  final String id;
  final String refCode;
  final String type; // 'lost' | 'found'
  final String title;
  final String? description;
  final String? image;
  final List<String> images;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? cityNameEn;
  final String? cityNameAr;
  final String? areaNameEn;
  final String? areaNameAr;
  final DateTime? itemDate;
  final String? status;
  final bool isDeleted;

  bool get isLost => type.toLowerCase() == 'lost';
  bool get isFound => type.toLowerCase() == 'found';

  String localizedCategory(String lang) => lang == 'ar'
      ? (categoryNameAr ?? categoryNameEn ?? '')
      : (categoryNameEn ?? categoryNameAr ?? '');

  String localizedArea(String lang) => lang == 'ar'
      ? (areaNameAr ?? areaNameEn ?? '')
      : (areaNameEn ?? areaNameAr ?? '');

  String? get primaryImage => image ?? (images.isNotEmpty ? images.first : null);

  @override
  List<Object?> get props => [
        id,
        refCode,
        type,
        title,
        description,
        image,
        images,
        categoryNameEn,
        categoryNameAr,
        cityNameEn,
        cityNameAr,
        areaNameEn,
        areaNameAr,
        itemDate,
        status,
        isDeleted,
      ];
}
