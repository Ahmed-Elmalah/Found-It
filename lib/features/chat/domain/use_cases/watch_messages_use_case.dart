import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  const WatchMessagesUseCase(this.repository);

  final ChatRepository repository;

  Stream<List<ChatMessageEntity>> call(String matchId) =>
      repository.getMessages(matchId);
}
