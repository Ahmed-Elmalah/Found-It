enum RecoveryFailureType {
  notFound,
  notAllowed,
  notVerified,
  invalidState,
  network,
  unknown,
}

class RecoveryFailure implements Exception {
  final RecoveryFailureType type;
  final String? message;

  const RecoveryFailure(this.type, [this.message]);

  @override
  String toString() => 'RecoveryFailure($type, $message)';
}
