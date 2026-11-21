enum MatchesFailureType {
  notFound,
  notAllowed,
  invalidState,
  network,
  unknown,
}

class MatchesFailure implements Exception {
  final MatchesFailureType type;
  final String? message;

  const MatchesFailure(this.type, [this.message]);

  @override
  String toString() => 'MatchesFailure($type, $message)';
}
