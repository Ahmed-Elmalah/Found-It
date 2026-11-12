import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.sortOrder = 0,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final int sortOrder;

  /// Returns the localized name based on [languageCode] ('ar' or 'en').
  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, sortOrder];
}
