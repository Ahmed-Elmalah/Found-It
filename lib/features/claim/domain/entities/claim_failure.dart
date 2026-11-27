import 'package:equatable/equatable.dart';

enum ClaimFailureType {
  /// `P0002` — the match is not yours / does not exist.
  notFound,

  /// `42501` — the finder (report owner) can't answer their own questions.
  notAllowed,

  /// `55000` — nothing to answer (already answered or the match is closed).
  invalidState,

  /// `22023` — a question is missing or answered twice.
  invalidInput,

  /// Expired or missing session (`PGRST301` / `PGRST302`).
  unauthorized,

  /// Any other Postgrest error.
  server,

  /// Timeout / no connection.
  network,

  /// Anything else; the raw message is never exposed.
  unknown,
}

class ClaimFailure extends Equatable implements Exception {
  const ClaimFailure(this.type, [this.code]);

  final ClaimFailureType type;

  /// Server code kept for debugging (never shown to the user).
  final String? code;

  @override
  List<Object?> get props => [type, code];

  @override
  String toString() => 'ClaimFailure($type, $code)';
}
