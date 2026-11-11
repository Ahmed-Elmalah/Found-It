import 'package:equatable/equatable.dart';

class AreaEntity extends Equatable {
  final String id;
  final String cityId;
  final String nameEn;
  final String nameAr;

  const AreaEntity({
    required this.id,
    required this.cityId,
    required this.nameEn,
    required this.nameAr,
  });

  String localizedName(String langCode) =>
      langCode.startsWith('ar') ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, cityId, nameEn, nameAr];
}
