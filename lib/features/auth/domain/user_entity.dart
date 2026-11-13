import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.address,
    this.cityId,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? address;

  /// Null until the user picks a city.
  final String? cityId;

  bool get hasCity => cityId != null;

  UserEntity copyWith({String? cityId}) => UserEntity(
    id: id,
    email: email,
    fullName: fullName,
    phone: phone,
    address: address,
    cityId: cityId ?? this.cityId,
  );

  @override
  List<Object?> get props => [id, email, fullName, phone, address, cityId];
}
