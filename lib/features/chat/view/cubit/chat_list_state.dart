import 'package:equatable/equatable.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

enum ChatListStatus {
  initial,
  loading,
  success,
  failure,
}

enum ChatFilter {
  all,
  unread,
  lost,
  found,
  verified,
}

class ChatListState extends Equatable {
  const ChatListState({
    this.status = ChatListStatus.initial,
    this.chats = const [],
    this.searchQuery = '',
    this.activeFilter = ChatFilter.all,
    this.failure,
  });

  final ChatListStatus status;
  final List<ChatItemEntity> chats;
  final String searchQuery;
  final ChatFilter activeFilter;
  final ChatFailureType? failure;

  List<ChatItemEntity> get filteredChats {
    var result = chats;

    // 1. Filter by category pill
    switch (activeFilter) {
      case ChatFilter.all:
        break;
      case ChatFilter.unread:
        result = result.where((c) => c.unreadCount > 0).toList();
      case ChatFilter.lost:
        result = result
            .where((c) => c.displayReport?.isLost ?? !c.iAmFinder)
            .toList();
      case ChatFilter.found:
        result = result
            .where((c) => c.displayReport?.isFound ?? c.iAmFinder)
            .toList();
      case ChatFilter.verified:
        result = result.where((c) => c.isVerified).toList();
    }

    // 2. Filter by search query
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return result;

    return result.where((chat) {
      final userName = chat.otherUserName.toLowerCase();
      final reportTitle = chat.displayReport?.title.toLowerCase() ?? '';
      final categoryEn =
          chat.displayReport?.categoryNameEn?.toLowerCase() ?? '';
      final categoryAr =
          chat.displayReport?.categoryNameAr?.toLowerCase() ?? '';
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
      (searchQuery.trim().isNotEmpty || activeFilter != ChatFilter.all) &&
      filteredChats.isEmpty;

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatItemEntity>? chats,
    String? searchQuery,
    ChatFilter? activeFilter,
    ChatFailureType? Function()? failure,
  }) {
    return ChatListState(
      status: status ?? this.status,
      chats: chats ?? this.chats,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chats,
        searchQuery,
        activeFilter,
        failure,
      ];
}
