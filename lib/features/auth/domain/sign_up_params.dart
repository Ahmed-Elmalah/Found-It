import 'package:equatable/equatable.dart';

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    required this.password,
  });

  final String fullName;
  final String email;

  /// Already normalized by the screen, e.g. `+20XXXXXXXXXX`.
  final String phone;
  final String? address;
  final String password;

  @override
  List<Object?> get props => [fullName, email, phone, address, password];
}
