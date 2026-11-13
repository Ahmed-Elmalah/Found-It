import 'package:equatable/equatable.dart';

/// An item category (Supabase `categories` table).
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  /// Material icon name stored in the database, e.g. `devices`.
  final String icon;

  /// The name in the app language (`en` / `ar`).
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, icon];
}
