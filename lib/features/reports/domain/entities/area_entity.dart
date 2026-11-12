import 'package:equatable/equatable.dart';

class AreaEntity extends Equatable {
  const AreaEntity({
    required this.id,
    required this.cityId,
    required this.nameEn,
    required this.nameAr,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String cityId;
  final String nameEn;
  final String nameAr;
  final bool isActive;
  final int sortOrder;

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, cityId, nameEn, nameAr, isActive, sortOrder];
}
