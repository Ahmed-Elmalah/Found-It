import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/data/mock/fake_chat_data.dart';
import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/get_my_chats_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_list_state.dart';

class _FakeChatRepository implements ChatRepository {
  List<ChatItemEntity> chatsToReturn = const [];
  Object? errorToThrow;

  @override
  Future<List<ChatItemEntity>> getMyChats() async {
    final err = errorToThrow;
    if (err != null) throw err;
    return chatsToReturn;
  }

  @override
  Future<int> getUnreadMessagesCount() async => 0;
}

void main() {
  group('ChatListCubit', () {
    late _FakeChatRepository repository;
    late GetMyChatsUseCase getMyChatsUseCase;
    late ChatListCubit cubit;

    setUp(() {
      repository = _FakeChatRepository();
      getMyChatsUseCase = GetMyChatsUseCase(repository);
      cubit = ChatListCubit(getMyChatsUseCase);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const ChatListState());
      expect(cubit.state.status, ChatListStatus.initial);
      expect(cubit.state.chats, isEmpty);
      expect(cubit.state.searchQuery, isEmpty);
      expect(cubit.state.activeFilter, ChatFilter.all);
      expect(cubit.state.failure, isNull);
    });

    test('loadChats emits [loading, success] on successful fetch', () async {
      final sample = FakeChatData.sampleChats;
      repository.chatsToReturn = sample;

      final expectedStates = [
        const ChatListState(status: ChatListStatus.loading),
        ChatListState(status: ChatListStatus.success, chats: sample),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadChats();
    });

    test('loadChats emits [loading, failure] on ChatFailure', () async {
      repository.errorToThrow = const ChatFailure(ChatFailureType.network);

      final expectedStates = [
        const ChatListState(status: ChatListStatus.loading),
        const ChatListState(
          status: ChatListStatus.failure,
          failure: ChatFailureType.network,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadChats();
    });

    test('loadChats emits [loading, failure] on generic Exception', () async {
      repository.errorToThrow = Exception('Something went wrong');

      final expectedStates = [
        const ChatListState(status: ChatListStatus.loading),
        const ChatListState(
          status: ChatListStatus.failure,
          failure: ChatFailureType.unknown,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadChats();
    });

    test('onSearchChanged updates query and filters chats correctly', () async {
      final sample = FakeChatData.sampleChats;
      repository.chatsToReturn = sample;
      await cubit.loadChats();

      expect(cubit.state.filteredChats.length, sample.length);

      cubit.onSearchChanged('mona');
      expect(cubit.state.searchQuery, 'mona');
      expect(cubit.state.filteredChats.length, 1);
      expect(cubit.state.filteredChats.first.otherUserName, 'Mona K.');

      // Search by report title
      cubit.onSearchChanged('airpods');
      expect(cubit.state.filteredChats.length, 1);
      expect(cubit.state.filteredChats.first.otherUserName, 'Omar S.');

      // Search with non-matching query
      cubit.onSearchChanged('nonexistent_123');
      expect(cubit.state.filteredChats, isEmpty);
      expect(cubit.state.isSearchEmpty, isTrue);

      // Clear search
      cubit.clearSearch();
      expect(cubit.state.searchQuery, isEmpty);
      expect(cubit.state.filteredChats.length, sample.length);
    });

    test('setFilter filters chats by category pills', () async {
      final sample = FakeChatData.sampleChats;
      repository.chatsToReturn = sample;
      await cubit.loadChats();

      // Filter unread
      cubit.setFilter(ChatFilter.unread);
      expect(
        cubit.state.filteredChats.every((c) => c.unreadCount > 0),
        isTrue,
      );

      // Filter verified
      cubit.setFilter(ChatFilter.verified);
      expect(
        cubit.state.filteredChats.every((c) => c.isVerified),
        isTrue,
      );

      // Reset to all
      cubit.setFilter(ChatFilter.all);
      expect(cubit.state.filteredChats.length, sample.length);
    });

    test('refresh updates chats silently without loading status', () async {
      final initialChats = [FakeChatData.sampleChats.first];
      repository.chatsToReturn = initialChats;
      await cubit.loadChats();

      final updatedChats = FakeChatData.sampleChats;
      repository.chatsToReturn = updatedChats;

      await cubit.refresh();

      expect(cubit.state.status, ChatListStatus.success);
      expect(cubit.state.chats.length, updatedChats.length);
    });
  });
}
