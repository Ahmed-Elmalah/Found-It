import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final bool isActive;
  final int sortOrder;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, isActive, sortOrder];
}
