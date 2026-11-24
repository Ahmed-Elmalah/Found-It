import 'package:equatable/equatable.dart';

import 'package:found_it/features/reports/domain/entities/report_entity.dart';
import 'package:found_it/features/reports/domain/entities/report_question_entity.dart';

class ReportDetailsEntity extends Equatable {
  final String id;
  final String refCode;
  final String type; // 'lost' | 'found'
  final String title;
  final String? description;
  final String categoryId;
  final String? categoryNameEn;
  final String? categoryNameAr;
  final String? categoryIcon;
  final String cityId;
  final String? cityNameEn;
  final String? cityNameAr;
  final String areaId;
  final String? areaNameEn;
  final String? areaNameAr;
  final DateTime itemDate;
  final List<String> images;
  final String status; // 'active' | 'matching' | 'recovered'
  final bool isMine;
  final String ownerName;
  final bool hasPrivateDetails;
  final String? privateDetails;
  final String? myMatchId;
  final String? myMatchStatus;
  final bool hasQuestions;
  final int questionsCount;
  final List<ReportQuestionEntity>? questions;
  final bool iAmBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReportDetailsEntity({
    required this.id,
    required this.refCode,
    required this.type,
    required this.title,
    this.description,
    required this.categoryId,
    this.categoryNameEn,
    this.categoryNameAr,
    this.categoryIcon,
    required this.cityId,
    this.cityNameEn,
    this.cityNameAr,
    required this.areaId,
    this.areaNameEn,
    this.areaNameAr,
    required this.itemDate,
    required this.images,
    required this.status,
    required this.isMine,
    required this.ownerName,
    required this.hasPrivateDetails,
    this.privateDetails,
    this.myMatchId,
    this.myMatchStatus,
    this.hasQuestions = false,
    this.questionsCount = 0,
    this.questions,
    this.iAmBlocked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLost => type == 'lost';
  bool get isFound => type == 'found';
  bool get isActive => status == 'active';
  bool get isMatching => status == 'matching';
  bool get isRecovered => status == 'recovered';

  bool get hasActiveMatchWithMe => myMatchId != null;

  String localizedCategory(String languageCode) =>
      (languageCode == 'ar' ? categoryNameAr : categoryNameEn) ?? categoryNameEn ?? '';

  String localizedCity(String languageCode) =>
      (languageCode == 'ar' ? cityNameAr : cityNameEn) ?? cityNameEn ?? '';

  String localizedArea(String languageCode) =>
      (languageCode == 'ar' ? areaNameAr : areaNameEn) ?? areaNameEn ?? '';

  ReportEntity toReportEntity() => ReportEntity(
        id: id,
        refCode: refCode,
        userId: '',
        type: type,
        title: title,
        description: description,
        categoryId: categoryId,
        categoryNameEn: categoryNameEn,
        categoryNameAr: categoryNameAr,
        categoryIcon: categoryIcon,
        cityId: cityId,
        cityNameEn: cityNameEn,
        cityNameAr: cityNameAr,
        areaId: areaId,
        areaNameEn: areaNameEn,
        areaNameAr: areaNameAr,
        itemDate: itemDate,
        images: images,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isMine: isMine,
        privateDetails: privateDetails,
      );

  @override
  List<Object?> get props => [
        id,
        refCode,
        type,
        title,
        description,
        categoryId,
        categoryNameEn,
        categoryNameAr,
        categoryIcon,
        cityId,
        cityNameEn,
        cityNameAr,
        areaId,
        areaNameEn,
        areaNameAr,
        itemDate,
        images,
        status,
        isMine,
        ownerName,
        hasPrivateDetails,
        privateDetails,
        myMatchId,
        myMatchStatus,
        hasQuestions,
        questionsCount,
        questions,
        iAmBlocked,
        createdAt,
        updatedAt,
      ];
}
