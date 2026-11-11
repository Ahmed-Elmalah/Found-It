import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/sign_up_params.dart';
import 'package:found_it/features/auth/domain/signup_use_case.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit(this._signUp) : super(const SignUpState());

  final SignUpUseCase _signUp;

  Future<void> submit(SignUpParams params) async {
    if (state.isSubmitting) return;
    emit(const SignUpState(status: SignUpStatus.submitting));
    try {
      await _signUp(params);
      if (isClosed) return;
      emit(const SignUpState(status: SignUpStatus.success));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(SignUpState(status: SignUpStatus.failure, failure: e.type));
    } catch (_) {
      if (isClosed) return;
      emit(
        const SignUpState(
          status: SignUpStatus.failure,
          failure: AuthFailureType.unknown,
        ),
      );
    }
  }

  void clearError() {
    if (state.status == SignUpStatus.failure) emit(const SignUpState());
  }
}
