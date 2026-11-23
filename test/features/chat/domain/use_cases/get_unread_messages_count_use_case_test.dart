import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/get_unread_messages_count_use_case.dart';

class _FakeChatRepository implements ChatRepository {
  int unreadCountToReturn = 5;

  @override
  Future<int> getUnreadMessagesCount() async => unreadCountToReturn;

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

  setUp(() {
    repository = _FakeChatRepository();
    useCase = GetUnreadMessagesCountUseCase(repository);
  });

  test('calls getUnreadMessagesCount on ChatRepository and returns the count', () async {
    repository.unreadCountToReturn = 7;
    final result = await useCase();
    expect(result, 7);
  });
}
