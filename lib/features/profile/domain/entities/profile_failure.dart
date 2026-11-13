enum ProfileFailureType {
  network,
  unknown,
}

class ProfileFailure implements Exception {
  final ProfileFailureType type;

  const ProfileFailure(this.type);

  @override
  String toString() => 'ProfileFailure($type)';
}
