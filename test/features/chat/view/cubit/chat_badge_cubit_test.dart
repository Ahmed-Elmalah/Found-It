import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/get_unread_messages_count_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_badge_cubit.dart';

class _FakeChatRepository implements ChatRepository {
  int unreadCountToReturn = 0;
  bool shouldThrow = false;

  @override
  Future<int> getUnreadMessagesCount() async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return unreadCountToReturn;
  }

  @override
  Future<void> confirmOwnership(String matchId) async {}

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) async =>
      const ChatItemEntity(matchId: '1', status: 'chatting', otherUserName: 'A');

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) =>
      const Stream.empty();

  @override
  Future<List<ChatItemEntity>> getMyChats() async => [];

  @override
  Future<String> getSignedImageUrl(String path) async => '';

  @override
  Future<void> markMessagesRead(String matchId) async {}

  @override
  Future<void> rejectMatch(String matchId) async {}

  @override
  Future<void> sendMessage(String matchId, {String? body, String? imagePath}) async {}

  @override
  Future<String> uploadChatImage(
      String matchId, List<int> bytes, String extension) async => '';
}

void main() {
  late _FakeChatRepository repository;
  late GetUnreadMessagesCountUseCase useCase;
  late ChatBadgeCubit cubit;

  setUp(() {
    repository = _FakeChatRepository();
    useCase = GetUnreadMessagesCountUseCase(repository);
    cubit = ChatBadgeCubit(useCase);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is 0', () {
    expect(cubit.state, 0);
  });

  test('loadUnreadCount emits fetched count on success', () async {
    repository.unreadCountToReturn = 4;
    await cubit.loadUnreadCount();
    expect(cubit.state, 4);
  });

  test('loadUnreadCount clamps negative count to 0', () async {
    repository.unreadCountToReturn = -1;
    await cubit.loadUnreadCount();
    expect(cubit.state, 0);
  });

  test('loadUnreadCount retains previous count on error', () async {
    cubit.updateCount(3);
    repository.shouldThrow = true;
    await cubit.loadUnreadCount();
    expect(cubit.state, 3);
  });

  test('updateCount updates state directly', () {
    cubit.updateCount(10);
    expect(cubit.state, 10);

    cubit.updateCount(-5);
    expect(cubit.state, 0);
  });

  test('decrement reduces state by specified amount', () {
    cubit.updateCount(5);
    cubit.decrement(2);
    expect(cubit.state, 3);

    cubit.decrement(5);
    expect(cubit.state, 0);
  });
}
