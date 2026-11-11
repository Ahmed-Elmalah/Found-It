import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/login_use_case.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginState());

  final LoginUseCase _login;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;
    emit(const LoginState(status: LoginStatus.submitting));
    try {
      await _login(email: email, password: password);
      if (isClosed) return;
      emit(const LoginState(status: LoginStatus.success));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(LoginState(status: LoginStatus.failure, failure: e.type));
    } catch (_) {
      if (isClosed) return;
      emit(
        const LoginState(
          status: LoginStatus.failure,
          failure: AuthFailureType.unknown,
        ),
      );
    }
  }

  void clearError() {
    if (state.status == LoginStatus.failure) emit(const LoginState());
  }
}
