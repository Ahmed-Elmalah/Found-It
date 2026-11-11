import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:found_it/features/auth/domain/auth_failure.dart';
import 'package:found_it/features/auth/domain/get_current_user_use_case.dart';
import 'package:found_it/features/auth/domain/has_active_session_use_case.dart';
import 'package:found_it/features/auth/domain/logout_use_case.dart';
import 'package:found_it/features/auth/domain/user_entity.dart';
import 'package:found_it/features/auth/domain/watch_auth_state_use_case.dart';

part 'auth_state.dart';

/// App-wide auth session: one instance (lazy singleton) provided at the app
/// root. Screens read it with `context.read<AuthCubit>()`.
///
/// Call [start] once at app start. The city screen calls [cityChanged] after
/// the user picks a city; Profile calls [logout].
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthStateUseCase watchAuthState,
    required GetCurrentUserUseCase getCurrentUser,
    required LogoutUseCase logout,
    required HasActiveSessionUseCase hasActiveSession,
  }) : this._(watchAuthState, getCurrentUser, logout, hasActiveSession);

  AuthCubit._(
    this._watchAuthState,
    this._getCurrentUser,
    this._logout,
    this._hasActiveSession,
  ) : super(const AuthState());

  final WatchAuthStateUseCase _watchAuthState;
  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;
  final HasActiveSessionUseCase _hasActiveSession;

  StreamSubscription<bool>? _subscription;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subscription = _watchAuthState().listen((signedIn) {
      if (signedIn) {
        _loadUser();
      } else {
        _emitSignedOut();
      }
    });
    if (_hasActiveSession()) {
      await _loadUser();
    } else {
      _emitSignedOut();
    }
  }

  Future<void> _loadUser() async {
    AuthState next;
    try {
      final user = await _getCurrentUser();
      next = user == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, user: user);
    } on AuthFailure {
      // Logged in but the profile is unknown (e.g. offline).
      next = const AuthState(status: AuthStatus.authenticated);
    }
    if (!isClosed) emit(next);
  }

  void _emitSignedOut() {
    if (!isClosed) emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Throws [AuthFailure] and keeps the current state when sign out fails.
  Future<void> logout() async {
    await _logout();
    _emitSignedOut();
  }

  void cityChanged(String cityId) {
    final user = state.user;
    if (user == null || isClosed) return;
    emit(
      AuthState(
        status: AuthStatus.authenticated,
        user: user.copyWith(cityId: cityId),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
