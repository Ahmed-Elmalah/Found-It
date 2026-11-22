import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';
import 'package:found_it/features/chat/view/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageEntity>>? _messagesSub;
  String? _currentMatchId;

  Future<void> init(String matchId, {ChatItemEntity? initialChatInfo}) async {
    _currentMatchId = matchId;
    emit(state.copyWith(
      status: ChatStatus.loading,
      chatInfo: () => initialChatInfo,
      isConfirmed: initialChatInfo?.isVerified ?? false,
    ));

    // 1. If chatInfo wasn't provided directly, try to locate it from getMyChats
    if (initialChatInfo == null) {
      try {
        final chats = await _repository.getMyChats();
        final found = chats.where((c) => c.matchId == matchId).firstOrNull;
        if (found != null) {
          emit(state.copyWith(
            chatInfo: () => found,
            isConfirmed: found.isVerified,
          ));
        }
      } catch (_) {}
    }

    // 2. Mark unread messages as read
    unawaited(_repository.markMessagesRead(matchId));

    // 3. Listen to realtime stream
    await _messagesSub?.cancel();
    try {
      _messagesSub = _repository.getMessages(matchId).listen(
        (remoteMessages) {
          emit(state.copyWith(
            status: ChatStatus.success,
            messages: remoteMessages,
          ));
        },
        onError: (err) {
          emit(state.copyWith(
            status: ChatStatus.failure,
            errorMessage: () => err.toString(),
          ));
        },
      );
    } catch (err) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: () => err.toString(),
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final matchId = _currentMatchId;
    final trimmed = text.trim();
    if (matchId == null || trimmed.isEmpty) return;

    // Optimistic UI message
    final optimisticMessage = ChatMessageEntity(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      senderId: 'me',
      body: trimmed,
      createdAt: DateTime.now(),
      isMine: true,
      isSending: true,
    );

    final updated = List<ChatMessageEntity>.from(state.messages)
      ..add(optimisticMessage);
    emit(state.copyWith(messages: updated, isSending: true));

    try {
      await _repository.sendMessage(matchId, body: trimmed);
      // Mark as sent
      final confirmed = state.messages.map((m) {
        if (m.id == optimisticMessage.id) {
          return m.copyWith(isSending: false);
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: confirmed, isSending: false));
    } catch (e) {
      final failed = state.messages.map((m) {
        if (m.id == optimisticMessage.id) {
          return m.copyWith(isSending: false);
        }
        return m;
      }).toList();
      emit(state.copyWith(
        messages: failed,
        isSending: false,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> sendImage(Uint8List bytes, String extension) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;

    emit(state.copyWith(isSending: true));
    try {
      final path = await _repository.uploadChatImage(matchId, bytes, extension);
      final signedUrl = await _repository.getSignedImageUrl(path);
      await _repository.sendMessage(matchId, imagePath: path);

      final photoMessage = ChatMessageEntity(
        id: 'local_img_${DateTime.now().millisecondsSinceEpoch}',
        matchId: matchId,
        senderId: 'me',
        imagePath: path,
        imageUrl: signedUrl,
        createdAt: DateTime.now(),
        isMine: true,
      );

      final updated = List<ChatMessageEntity>.from(state.messages)
        ..add(photoMessage);
      emit(state.copyWith(messages: updated, isSending: false));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: () => 'Failed to send image',
      ));
    }
  }

  Future<bool> confirmOwnership() async {
    final matchId = _currentMatchId;
    if (matchId == null) return false;

    emit(state.copyWith(isConfirming: true));
    try {
      await _repository.confirmOwnership(matchId);
      emit(state.copyWith(
        isConfirming: false,
        isConfirmed: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isConfirming: false,
        errorMessage: () => e.toString(),
      ));
      return false;
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
