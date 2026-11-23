import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/confirm_ownership_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_chat_match_details_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_my_chats_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_signed_image_url_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/mark_messages_read_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/reject_chat_match_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/upload_chat_image_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/watch_messages_use_case.dart';

class _FakeChatRepository implements ChatRepository {
  String? lastConfirmedMatchId;
  String? lastRejectedMatchId;
  String? lastMarkedReadMatchId;
  String? lastSentMessageMatchId;
  String? lastSentBody;
  String? lastSentImagePath;
  String? lastUploadedMatchId;
  List<int>? lastUploadedBytes;
  String? lastUploadedExtension;
  String? lastSignedPath;

  ChatItemEntity matchDetailsToReturn = const ChatItemEntity(
    matchId: 'match-1',
    status: 'chatting',
    otherUserName: 'Sara',
    iAmFinder: true,
  );

  List<ChatMessageEntity> messagesToReturn = [
    ChatMessageEntity(
      id: 'm1',
      matchId: 'match-1',
      senderId: 'me',
      body: 'Hello',
      createdAt: DateTime(2026, 11, 23),
    ),
  ];

  @override
  Future<void> confirmOwnership(String matchId) async {
    lastConfirmedMatchId = matchId;
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    lastRejectedMatchId = matchId;
  }

  @override
  Future<void> markMessagesRead(String matchId) async {
    lastMarkedReadMatchId = matchId;
  }

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) async =>
      matchDetailsToReturn;

  @override
  Future<List<ChatItemEntity>> getMyChats() async => [matchDetailsToReturn];

  @override
  Future<int> getUnreadMessagesCount() async => 3;

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) =>
      Stream.value(messagesToReturn);

  @override
  Future<void> sendMessage(String matchId, {String? body, String? imagePath}) async {
    lastSentMessageMatchId = matchId;
    lastSentBody = body;
    lastSentImagePath = imagePath;
  }

  @override
  Future<String> uploadChatImage(
      String matchId, List<int> bytes, String extension) async {
    lastUploadedMatchId = matchId;
    lastUploadedBytes = bytes;
    lastUploadedExtension = extension;
    return 'path/to/image.jpg';
  }

  @override
  Future<String> getSignedImageUrl(String path) async {
    lastSignedPath = path;
    return 'https://signed.url/$path';
  }
}

void main() {
  late _FakeChatRepository repo;

  setUp(() {
    repo = _FakeChatRepository();
  });

  group('Chat Domain UseCases', () {
    test('GetMyChatsUseCase delegates call to repository', () async {
      final useCase = GetMyChatsUseCase(repo);
      final result = await useCase();
      expect(result, [repo.matchDetailsToReturn]);
    });

    test('GetChatMatchDetailsUseCase delegates call to repository', () async {
      final useCase = GetChatMatchDetailsUseCase(repo);
      final result = await useCase('match-1');
      expect(result.matchId, 'match-1');
      expect(result.otherUserName, 'Sara');
    });

    test('WatchMessagesUseCase delegates call to repository stream', () async {
      final useCase = WatchMessagesUseCase(repo);
      final stream = useCase('match-1');
      final messages = await stream.first;
      expect(messages.length, 1);
      expect(messages.first.body, 'Hello');
    });

    test('SendMessageUseCase delegates call to repository with text and image', () async {
      final useCase = SendMessageUseCase(repo);
      await useCase('match-1', body: 'Hey there', imagePath: 'images/img.jpg');
      expect(repo.lastSentMessageMatchId, 'match-1');
      expect(repo.lastSentBody, 'Hey there');
      expect(repo.lastSentImagePath, 'images/img.jpg');
    });

    test('ConfirmOwnershipUseCase delegates call to repository', () async {
      final useCase = ConfirmOwnershipUseCase(repo);
      await useCase('match-1');
      expect(repo.lastConfirmedMatchId, 'match-1');
    });

    test('RejectChatMatchUseCase delegates call to repository', () async {
      final useCase = RejectChatMatchUseCase(repo);
      await useCase('match-1');
      expect(repo.lastRejectedMatchId, 'match-1');
    });

    test('MarkMessagesReadUseCase delegates call to repository', () async {
      final useCase = MarkMessagesReadUseCase(repo);
      await useCase('match-1');
      expect(repo.lastMarkedReadMatchId, 'match-1');
    });

    test('UploadChatImageUseCase delegates call to repository and returns storage path', () async {
      final useCase = UploadChatImageUseCase(repo);
      final path = await useCase('match-1', [1, 2, 3], 'jpg');
      expect(repo.lastUploadedMatchId, 'match-1');
      expect(repo.lastUploadedBytes, [1, 2, 3]);
      expect(repo.lastUploadedExtension, 'jpg');
      expect(path, 'path/to/image.jpg');
    });

    test('GetSignedImageUrlUseCase delegates call to repository and returns signed url', () async {
      final useCase = GetSignedImageUrlUseCase(repo);
      final url = await useCase('match-1/photo.jpg');
      expect(repo.lastSignedPath, 'match-1/photo.jpg');
      expect(url, 'https://signed.url/match-1/photo.jpg');
    });
  });
}
