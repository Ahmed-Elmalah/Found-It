import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';

class HandoverContactModel extends HandoverContactEntity {
  const HandoverContactModel({
    required super.fullName,
    super.phone,
    required super.email,
  });

  factory HandoverContactModel.fromJson(Map<String, dynamic> json) {
    return HandoverContactModel(
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        if (phone != null) 'phone': phone,
        'email': email,
      };
}
