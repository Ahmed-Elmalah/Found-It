import 'package:equatable/equatable.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

enum ChatListStatus {
  initial,
  loading,
  success,
  failure,
}

class ChatListState extends Equatable {
  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.searchQuery = '',
    this.failure,
  });

  final ChatListStatus status;
  final List<ChatItemEntity> chats;
  final String searchQuery;
  final ChatFailureType? failure;

  List<ChatItemEntity> get filteredChats {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return chats;

    return chats.where((chat) {
      final userName = chat.otherUserName.toLowerCase();
      final reportTitle = chat.displayReport?.title.toLowerCase() ?? '';
      final categoryEn = chat.displayReport?.categoryNameEn?.toLowerCase() ?? '';
      final categoryAr = chat.displayReport?.categoryNameAr?.toLowerCase() ?? '';
      final lastMsg = chat.lastMessage?.body?.toLowerCase() ?? '';

      return userName.contains(query) ||
          reportTitle.contains(query) ||
          categoryEn.contains(query) ||
          categoryAr.contains(query) ||
          lastMsg.contains(query);
    }).toList();
  }

  bool get isEmpty => status == ChatListStatus.success && chats.isEmpty;

  bool get isSearchEmpty =>
      status == ChatListStatus.success &&
      searchQuery.trim().isNotEmpty &&
      filteredChats.isEmpty;

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatItemEntity>? chats,
    String? searchQuery,
    ChatFailureType? Function()? failure,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chats,
        searchQuery,
        failure,
      ];
}
