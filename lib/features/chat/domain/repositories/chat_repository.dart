import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';

abstract interface class ChatRepository {
  /// Fetches all active and closed chats for the authenticated user (P31).
  Future<List<ChatItemEntity>> getMyChats();

  /// Gets match details for a specific match header (P32), even if no messages yet.
  Future<ChatItemEntity> getMatchDetails(String matchId);

  /// Gets the total unread messages count across all active chats for badge display.
  Future<int> getUnreadMessagesCount();

  /// Subscribes to realtime messages for a match (P32).
  Stream<List<ChatMessageEntity>> getMessages(String matchId);

  /// Sends a text or photo message inside a chat.
  Future<void> sendMessage(String matchId, {String? body, String? imagePath});

  /// Marks unread messages in this chat as read.
  Future<void> markMessagesRead(String matchId);

  /// Confirms ownership verification for the lost item (Finder only, chatting status).
  Future<void> confirmOwnership(String matchId);

  /// Uploads a photo to the private chat-images storage bucket.
  Future<String> uploadChatImage(
    String matchId,
    List<int> bytes,
    String extension,
  );

  /// Gets a temporary signed URL to view a private chat image.
  Future<String> getSignedImageUrl(String path);
}
