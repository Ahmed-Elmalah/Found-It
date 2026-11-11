part of 'auth_cubit.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

final class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user});

  final AuthStatus status;

  /// Null when logged out, or logged in but the profile could not be loaded.
  final UserEntity? user;

  /// Null while the session is still being checked.
  bool? get isLoggedIn => switch (status) {
    AuthStatus.unknown => null,
    AuthStatus.unauthenticated => false,
    AuthStatus.authenticated => true,
  };

  /// Null when logged out or when the profile is unknown.
  bool? get hasCity => user?.hasCity;

  @override
  List<Object?> get props => [status, user];
}
