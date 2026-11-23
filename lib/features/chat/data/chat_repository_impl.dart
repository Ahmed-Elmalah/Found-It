import 'package:found_it/features/chat/data/chat_remote_data_source.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  final ChatRemoteDataSource remoteDataSource;

  @override
  Future<List<ChatItemEntity>> getMyChats() => remoteDataSource.getMyChats();

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) =>
      remoteDataSource.getMatchDetails(matchId);

  @override
  Future<int> getUnreadMessagesCount() =>
      remoteDataSource.getUnreadMessagesCount();

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
