part of 'sign_up_cubit.dart';

enum SignUpStatus { initial, submitting, success, failure }

final class SignUpState extends Equatable {
  const SignUpState({this.status = SignUpStatus.initial, this.failure});

  final SignUpStatus status;
  final AuthFailureType? failure;

  bool get isSubmitting => status == SignUpStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
