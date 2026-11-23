import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class MarkMessagesReadUseCase {
  const MarkMessagesReadUseCase(this.repository);

  final ChatRepository repository;

  Future<void> call(String matchId) => repository.markMessagesRead(matchId);
}
