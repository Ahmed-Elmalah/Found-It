/// What went wrong while talking to Supabase from Explore.
enum ExploreFailureType { network, invalidData, notFound, notAllowed, unknown }

/// Typed error thrown by the Explore repository, so the Cubit never has to
/// know about `PostgrestException`.
class ExploreFailure implements Exception {
  const ExploreFailure(this.type);

  final ExploreFailureType type;

  /// A short, readable description (the UI shows its own localized text).
  String get message => switch (type) {
    ExploreFailureType.network => 'Network error',
    ExploreFailureType.invalidData => 'Invalid search filters',
    ExploreFailureType.notFound => 'Reports not found',
    ExploreFailureType.notAllowed => 'You are not allowed to do that',
    ExploreFailureType.unknown => 'Something went wrong',
  };

  @override
  String toString() => 'ExploreFailure(${type.name}): $message';
}
