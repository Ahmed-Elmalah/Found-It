import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class GetMyChatsUseCase {
  const GetMyChatsUseCase(this._repository);

  final ChatRepository _repository;

  Future<List<ChatItemEntity>> call() => _repository.getMyChats();
}
