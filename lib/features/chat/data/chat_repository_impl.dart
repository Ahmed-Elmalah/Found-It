import 'package:found_it/features/chat/data/chat_remote_data_source.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  final ChatRemoteDataSource remoteDataSource;

  @override
  Future<List<ChatItemEntity>> getMyChats() async {
    try {
      return await remoteDataSource.getMyChats();
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }

  @override
  Future<int> getUnreadMessagesCount() async {
    try {
      return await remoteDataSource.getUnreadMessagesCount();
    } catch (e) {
      if (e is ChatFailure) rethrow;
      throw ChatFailure(ChatFailureType.unknown, e.toString());
    }
  }
}
