import 'package:found_it/features/chat/data/chat_remote_data_source.dart';
import 'package:found_it/features/chat/data/mock/fake_chat_data.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  final ChatRemoteDataSource remoteDataSource;

  @override
  Future<List<ChatItemEntity>> getMyChats() async {
    try {
      final remote = await remoteDataSource.getMyChats();
      if (remote.isNotEmpty) return remote;
      // Test dummy chats for preview & testing in UI
      return FakeChatData.sampleChats;
    } catch (_) {
      return FakeChatData.sampleChats;
    }
  }

  @override
  Future<int> getUnreadMessagesCount() async {
    try {
      final count = await remoteDataSource.getUnreadMessagesCount();
      if (count > 0) return count;
      return FakeChatData.sampleChats.fold<int>(
        0,
        (acc, c) => acc + c.unreadCount,
      );
    } catch (_) {
      return FakeChatData.sampleChats.fold<int>(
        0,
        (acc, c) => acc + c.unreadCount,
      );
    }
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) =>
      remoteDataSource.getMessages(matchId);

  @override
  Future<void> sendMessage(
    String matchId, {
    String? body,
    String? imagePath,
  }) =>
      remoteDataSource.sendMessage(matchId, body: body, imagePath: imagePath);

  @override
  Future<void> markMessagesRead(String matchId) =>
      remoteDataSource.markMessagesRead(matchId);

  @override
  Future<void> confirmOwnership(String matchId) =>
      remoteDataSource.confirmOwnership(matchId);

  @override
  Future<String> uploadChatImage(
    String matchId,
    List<int> bytes,
    String extension,
  ) =>
      remoteDataSource.uploadChatImage(matchId, bytes, extension);

  @override
  Future<String> getSignedImageUrl(String path) =>
      remoteDataSource.getSignedImageUrl(path);
}
