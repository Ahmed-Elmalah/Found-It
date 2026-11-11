part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

final class LoginState extends Equatable {
  const LoginState({this.status = LoginStatus.initial, this.failure});

  final LoginStatus status;
  final AuthFailureType? failure;

  bool get isSubmitting => status == LoginStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
