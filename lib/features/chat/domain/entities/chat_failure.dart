enum ChatFailureType {
  notFound,
  notAllowed,
  invalidState,
  network,
  unknown,
}

class ChatFailure implements Exception {
  const ChatFailure(this.type, [this.message]);

  final ChatFailureType type;
  final String? message;

  @override
  String toString() => 'ChatFailure($type, $message)';
}
