import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  const UserProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.address,
    this.avatarUrl,
    required this.role,
    this.cityId,
    this.cityNameEn,
    this.cityNameAr,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? address;
  final String? avatarUrl;
  final String role;
  final String? cityId;
  final String? cityNameEn;
  final String? cityNameAr;
  final DateTime createdAt;

  String localizedCity(String languageCode) =>
      languageCode == 'ar' ? (cityNameAr ?? '') : (cityNameEn ?? '');

  UserProfileEntity copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? avatarUrl,
    String? cityId,
    String? cityNameEn,
    String? cityNameAr,
  }) {
    return UserProfileEntity(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      cityId: cityId ?? this.cityId,
      cityNameEn: cityNameEn ?? this.cityNameEn,
      cityNameAr: cityNameAr ?? this.cityNameAr,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        address,
        avatarUrl,
        role,
        cityId,
        cityNameEn,
        cityNameAr,
        createdAt,
      ];
}
