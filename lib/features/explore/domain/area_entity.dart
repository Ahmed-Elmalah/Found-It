import 'package:equatable/equatable.dart';

/// A district inside a city (Supabase `areas` table).
class AreaEntity extends Equatable {
  const AreaEntity({
    required this.id,
    required this.cityId,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String cityId;
  final String nameEn;
  final String nameAr;

  /// The name in the app language (`en` / `ar`).
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, cityId, nameEn, nameAr];
}
