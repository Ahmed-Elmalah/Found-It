import 'package:found_it/features/reports/data/models/report_question_model.dart';
import 'package:found_it/features/reports/domain/entities/report_details_entity.dart';

class ReportDetailsModel extends ReportDetailsEntity {
  const ReportDetailsModel({
    required super.id,
    required super.refCode,
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
    required super.isMine,
    required super.ownerName,
    required super.hasPrivateDetails,
    super.privateDetails,
    super.myMatchId,
    super.myMatchStatus,
    super.hasQuestions,
    super.questionsCount,
    super.questions,
    super.iAmBlocked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReportDetailsModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final imagesRaw = json['images'];
    List<String> images = const [];
    if (imagesRaw is List) {
      images = imagesRaw.map((e) => e.toString()).toList();
    } else if (json['image'] is String && (json['image'] as String).isNotEmpty) {
      images = [json['image'] as String];
    }

    final questionsRaw = json['questions'];
    List<ReportQuestionModel>? questions;
    if (questionsRaw is List) {
      questions = questionsRaw
          .whereType<Map<String, dynamic>>()
          .map(ReportQuestionModel.fromJson)
          .toList();
    }

    return ReportDetailsModel(
      id: json['id'] as String? ?? '',
      refCode: json['ref_code'] as String? ?? '',
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
      itemDate: parseDate(json['item_date']),
      images: images,
      status: json['status'] as String? ?? 'active',
      isMine: json['is_mine'] as bool? ?? false,
      ownerName: json['owner_name'] as String? ?? 'User',
      hasPrivateDetails: json['has_private_details'] as bool? ?? false,
      privateDetails: json['private_details'] as String?,
      myMatchId: json['my_match_id'] as String?,
      myMatchStatus: json['my_match_status'] as String?,
      hasQuestions: json['has_questions'] as bool? ?? false,
      questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
      questions: questions,
      iAmBlocked: json['i_am_blocked'] as bool? ?? false,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
