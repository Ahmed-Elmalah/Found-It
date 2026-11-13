import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.icon = '',
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String icon;
  final bool isActive;
  final int sortOrder;

  String localizedName(String langCode) =>
      langCode.startsWith('ar') ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, icon, isActive, sortOrder];
}
