enum ReportFailureType {
  network,
  notLoggedIn,
  invalidData,
  notFound,
  notAllowed,
  invalidState,
  invalidInput,
  unknown,
}

class ReportFailure implements Exception {
  final ReportFailureType type;

  const ReportFailure(this.type);

  @override
  String toString() => 'ReportFailure($type)';
}
