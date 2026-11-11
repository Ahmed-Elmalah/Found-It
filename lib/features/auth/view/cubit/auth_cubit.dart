import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

// Filled in at stage 8 (login / sign up / logout use cases).
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());
}
