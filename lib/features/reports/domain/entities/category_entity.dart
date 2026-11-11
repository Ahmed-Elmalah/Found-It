import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final String icon;

  const CategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
  });

  String localizedName(String langCode) =>
      langCode.startsWith('ar') ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, icon];
}
