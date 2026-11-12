import 'package:found_it/features/auth/domain/user_entity.dart';

class AuthModel extends UserEntity {
  const AuthModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.address,
    super.cityId,
  });

  /// Reads a row of the `get_my_profile` RPC.
  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: (json['full_name'] as String?) ?? '',
    phone: json['phone'] as String?,
    address: json['address'] as String?,
    cityId: json['city_id'] as String?,
  );
}
