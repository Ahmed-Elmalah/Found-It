import 'package:equatable/equatable.dart';

enum NotificationsFailureType { network, unauthorized, server, unknown }

class NotificationsFailure extends Equatable implements Exception {
  const NotificationsFailure(this.type, [this.code]);

  final NotificationsFailureType type;

  /// Postgrest / network code for debugging (never shown to the user).
  final String? code;

  @override
  List<Object?> get props => [type, code];

  @override
  String toString() => 'NotificationsFailure($type, $code)';
}
