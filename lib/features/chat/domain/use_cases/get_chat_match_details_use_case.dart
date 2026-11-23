import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class GetChatMatchDetailsUseCase {
  const GetChatMatchDetailsUseCase(this.repository);

  final ChatRepository repository;

  Future<ChatItemEntity> call(String matchId) =>
      repository.getMatchDetails(matchId);
}
