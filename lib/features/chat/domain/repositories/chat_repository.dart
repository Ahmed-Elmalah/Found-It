import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

abstract interface class ChatRepository {
  /// Fetches all active and closed chats for the authenticated user (P31).
  Future<List<ChatItemEntity>> getMyChats();

  /// Gets the total unread messages count across all active chats for badge display.
  Future<int> getUnreadMessagesCount();
}
