import 'package:equatable/equatable.dart';

/// A city reports belong to (Supabase `cities` table).
class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  /// The name in the app language (`en` / `ar`).
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}
