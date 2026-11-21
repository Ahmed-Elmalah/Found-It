import 'package:equatable/equatable.dart';

class HandoverContactEntity extends Equatable {
  final String fullName;
  final String? phone;
  final String email;

  const HandoverContactEntity({
    required this.fullName,
    this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, phone, email];
}
