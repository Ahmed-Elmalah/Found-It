import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/domain/use_cases/confirm_ownership_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_chat_match_details_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_signed_image_url_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/mark_messages_read_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/reject_chat_match_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/upload_chat_image_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/watch_messages_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_state.dart';

class _FakeChatRepository implements ChatRepository {
  StreamController<List<ChatMessageEntity>> messagesController =
      StreamController<List<ChatMessageEntity>>.broadcast();

  ChatItemEntity matchDetailsToReturn = const ChatItemEntity(
    matchId: 'match-123',
    status: 'chatting',
    otherUserName: 'Sara Ahmed',
    iAmFinder: true,
  );

  bool failNextSendMessage = false;
  bool failNextConfirm = false;
  bool failNextReject = false;
  int markReadCallCount = 0;
  List<String> signedUrlPathsRequested = [];

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) async =>
      matchDetailsToReturn;

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) =>
      messagesController.stream;

  @override
  Future<void> sendMessage(String matchId, {String? body, String? imagePath}) async {
    if (failNextSendMessage) {
      throw const ChatFailure(ChatFailureType.network, 'Connection lost');
    }
  }

  @override
  Future<void> markMessagesRead(String matchId) async {
    markReadCallCount++;
  }

  @override
  Future<void> confirmOwnership(String matchId) async {
    if (failNextConfirm) {
      throw const ChatFailure(ChatFailureType.invalidState, 'Invalid state');
    }
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    if (failNextReject) {
      throw const ChatFailure(ChatFailureType.invalidState, 'Already closed');
    }
  }

  @override
  Future<String> uploadChatImage(
      String matchId, List<int> bytes, String extension) async {
    return 'match-123/img.jpg';
  }

  @override
  Future<String> getSignedImageUrl(String path) async {
    signedUrlPathsRequested.add(path);
    return 'https://signed.url/$path';
  }

  @override
  Future<List<ChatItemEntity>> getMyChats() async => [matchDetailsToReturn];

  @override
  Future<int> getUnreadMessagesCount() async => 0;
}

void main() {
  late _FakeChatRepository fakeRepo;
  late ChatCubit cubit;

  setUp(() {
    fakeRepo = _FakeChatRepository();
    cubit = ChatCubit(
      getChatMatchDetailsUseCase: GetChatMatchDetailsUseCase(fakeRepo),
      watchMessagesUseCase: WatchMessagesUseCase(fakeRepo),
      sendMessageUseCase: SendMessageUseCase(fakeRepo),
      uploadChatImageUseCase: UploadChatImageUseCase(fakeRepo),
      getSignedImageUrlUseCase: GetSignedImageUrlUseCase(fakeRepo),
      markMessagesReadUseCase: MarkMessagesReadUseCase(fakeRepo),
      confirmOwnershipUseCase: ConfirmOwnershipUseCase(fakeRepo),
      rejectChatMatchUseCase: RejectChatMatchUseCase(fakeRepo),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('init loads match details, starts stream, and marks messages read', () async {
    await cubit.init('match-123');

    expect(cubit.state.status, ChatStatus.loading);
    // Allow unawaited _loadMatchDetails to complete
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state.chatInfo?.otherUserName, 'Sara Ahmed');
    expect(cubit.state.isFinder, true);
    expect(cubit.state.canConfirmOwnership, true);
    expect(fakeRepo.markReadCallCount, 1);
  });

  test('first message reloads match details so the finder can confirm', () async {
    fakeRepo.matchDetailsToReturn = const ChatItemEntity(
      matchId: 'match-123',
      status: 'potential',
      otherUserName: 'Sara Ahmed',
      iAmFinder: true,
    );
    await cubit.init('match-123');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.canConfirmOwnership, false);

    // the server moved the match to "chatting" when the first message arrived
    fakeRepo.matchDetailsToReturn = const ChatItemEntity(
      matchId: 'match-123',
      status: 'chatting',
      otherUserName: 'Sara Ahmed',
      iAmFinder: true,
    );
    fakeRepo.messagesController.add([
      ChatMessageEntity(
        id: 'msg-1',
        matchId: 'match-123',
        senderId: 'other-user',
        body: 'Hi, I think it is mine',
        createdAt: DateTime.now(),
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.chatInfo?.status, 'chatting');
    expect(cubit.state.canConfirmOwnership, true);
  });

  test('a message arriving after the chat is closed does not throw', () async {
    await cubit.init('match-123');
    await cubit.close();

    fakeRepo.messagesController.add([
      ChatMessageEntity(
        id: 'msg-late',
        matchId: 'match-123',
        senderId: 'other-user',
        imagePath: 'match-123/late.jpg',
        createdAt: DateTime.now(),
      ),
    ]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.isClosed, true);
  });

  test('incoming messages with photo fetches signed URL once and caches it', () async {
    await cubit.init('match-123');

    final msg = ChatMessageEntity(
      id: 'msg-1',
      matchId: 'match-123',
      senderId: 'other-user',
      imagePath: 'match-123/photo.jpg',
      createdAt: DateTime.now(),
      isMine: false,
    );

    fakeRepo.messagesController.add([msg]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(cubit.state.messages.length, 1);
    expect(cubit.state.messages.first.imageUrl, 'https://signed.url/match-123/photo.jpg');
    expect(fakeRepo.signedUrlPathsRequested, ['match-123/photo.jpg']);

    // Emitting same message again should NOT refetch signed URL (cached)
    fakeRepo.messagesController.add([msg]);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(fakeRepo.signedUrlPathsRequested.length, 1);
  });

  test('incoming unread message from other user calls markMessagesRead', () async {
    await cubit.init('match-123');
    final initialCount = fakeRepo.markReadCallCount;

    final unreadMsg = ChatMessageEntity(
      id: 'msg-2',
      matchId: 'match-123',
      senderId: 'other-user',
      body: 'Hello',
      createdAt: DateTime.now(),
      isMine: false,
      readAt: null,
    );

    fakeRepo.messagesController.add([unreadMsg]);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(fakeRepo.markReadCallCount, greaterThan(initialCount));
  });

  test('sendMessage optimistic add then confirms on success', () async {
    await cubit.init('match-123');

    await cubit.sendMessage('Test message');

    expect(cubit.state.messages.length, 1);
    expect(cubit.state.messages.first.body, 'Test message');
    expect(cubit.state.messages.first.isSending, false);
    expect(cubit.state.messages.first.hasFailed, false);
  });

  test('sendMessage failure marks message as failed with retry state', () async {
    await cubit.init('match-123');
    fakeRepo.failNextSendMessage = true;

    await cubit.sendMessage('Failing message');

    expect(cubit.state.messages.length, 1);
    expect(cubit.state.messages.first.isSending, false);
    expect(cubit.state.messages.first.hasFailed, true);
    expect(cubit.state.failure?.type, ChatFailureType.network);
  });

  test('retryMessage re-attempts sending failed message', () async {
    await cubit.init('match-123');
    fakeRepo.failNextSendMessage = true;

    await cubit.sendMessage('Failing message');
    expect(cubit.state.messages.first.hasFailed, true);

    fakeRepo.failNextSendMessage = false;
    final failedId = cubit.state.messages.first.id;

    await cubit.retryMessage(failedId);

    expect(cubit.state.messages.first.hasFailed, false);
    expect(cubit.state.messages.first.isSending, false);
  });

  test('confirmOwnership succeeds and updates isConfirmed', () async {
    await cubit.init('match-123');

    final result = await cubit.confirmOwnership();

    expect(result, true);
    expect(cubit.state.isConfirmed, true);
    expect(cubit.state.isVerified, true);
  });

  test('confirmOwnership failure updates failure state', () async {
    await cubit.init('match-123');
    fakeRepo.failNextConfirm = true;

    final result = await cubit.confirmOwnership();

    expect(result, false);
    expect(cubit.state.isConfirmed, false);
    expect(cubit.state.failure?.type, ChatFailureType.invalidState);
  });

  test('rejectMatch succeeds and updates chatInfo status to rejected (isClosed true)', () async {
    await cubit.init('match-123');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final result = await cubit.rejectMatch();

    expect(result, true);
    expect(cubit.state.chatInfo?.status, 'rejected');
    expect(cubit.state.isClosed, true);
  });

  test('rejectMatch failure updates failure state', () async {
    await cubit.init('match-123');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    fakeRepo.failNextReject = true;
    final result = await cubit.rejectMatch();

    expect(result, false);
    expect(cubit.state.failure?.type, ChatFailureType.invalidState);
  });
}
