import 'dart:async';

import 'package:found_it/features/chat/data/chat_remote_data_source.dart';
import 'package:found_it/features/chat/data/mock/fake_chat_data.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  final ChatRemoteDataSource remoteDataSource;

  // Local simulated stream controller for test messages
  final Map<String, StreamController<List<ChatMessageEntity>>>
      _mockStreamControllers = {};
  final Map<String, List<ChatMessageEntity>> _mockMessagesCache = {};

  @override
  Future<List<ChatItemEntity>> getMyChats() async {
    try {
      final remote = await remoteDataSource.getMyChats();
      if (remote.isNotEmpty) return remote;
      return FakeChatData.sampleChats;
    } catch (_) {
      return FakeChatData.sampleChats;
    }
  }

  @override
  Future<ChatItemEntity> getMatchDetails(String matchId) async {
    if (matchId.startsWith('m-')) {
      final found = FakeChatData.sampleChats
          .where((c) => c.matchId == matchId)
          .firstOrNull;
      if (found != null) return found;
    }
    try {
      return await remoteDataSource.getMatchDetails(matchId);
    } catch (_) {
      final found = FakeChatData.sampleChats
          .where((c) => c.matchId == matchId)
          .firstOrNull;
      if (found != null) return found;
      rethrow;
    }
  }

  @override
  Future<int> getUnreadMessagesCount() async {
    try {
      final count = await remoteDataSource.getUnreadMessagesCount();
      if (count > 0) return count;
      return FakeChatData.sampleChats.fold<int>(
        0,
        (acc, c) => acc + c.unreadCount,
      );
    } catch (_) {
      return FakeChatData.sampleChats.fold<int>(
        0,
        (acc, c) => acc + c.unreadCount,
      );
    }
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String matchId) {
    if (matchId.startsWith('m-')) {
      if (!_mockStreamControllers.containsKey(matchId)) {
        final controller =
            StreamController<List<ChatMessageEntity>>.broadcast();
        final initial = FakeChatData.sampleMessages(matchId);
        _mockMessagesCache[matchId] = List.from(initial);
        _mockStreamControllers[matchId] = controller;
        Future.microtask(() {
          if (!controller.isClosed) {
            controller.add(_mockMessagesCache[matchId]!);
          }
        });
      }
      return _mockStreamControllers[matchId]!.stream;
    }
    return remoteDataSource.getMessages(matchId);
  }

  @override
  Future<void> sendMessage(
    String matchId, {
    String? body,
    String? imagePath,
  }) async {
    if (matchId.startsWith('m-')) {
      final msg = ChatMessageEntity(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        matchId: matchId,
        senderId: 'me',
        body: body,
        imagePath: imagePath,
        imageUrl: imagePath != null
            ? 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=600&q=80'
            : null,
        createdAt: DateTime.now(),
        isMine: true,
      );
      _mockMessagesCache[matchId]?.add(msg);
      _mockStreamControllers[matchId]
          ?.add(List.from(_mockMessagesCache[matchId] ?? []));
      return;
    }
    return remoteDataSource.sendMessage(matchId,
        body: body, imagePath: imagePath);
  }

  @override
  Future<void> markMessagesRead(String matchId) async {
    if (matchId.startsWith('m-')) return;
    return remoteDataSource.markMessagesRead(matchId);
  }

  @override
  Future<void> confirmOwnership(String matchId) async {
    if (matchId.startsWith('m-')) return;
    return remoteDataSource.confirmOwnership(matchId);
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    if (matchId.startsWith('m-')) return;
    return remoteDataSource.rejectMatch(matchId);
  }

  @override
  Future<String> uploadChatImage(
    String matchId,
    List<int> bytes,
    String extension,
  ) async {
    if (matchId.startsWith('m-')) {
      return '$matchId/mock_photo.jpg';
    }
    return remoteDataSource.uploadChatImage(matchId, bytes, extension);
  }

  @override
  Future<String> getSignedImageUrl(String path) async {
    if (path.startsWith('m-')) {
      return 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?auto=format&fit=crop&w=600&q=80';
    }
    return remoteDataSource.getSignedImageUrl(path);
  }
}
