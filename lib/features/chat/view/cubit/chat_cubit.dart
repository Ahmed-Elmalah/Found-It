import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';
import 'package:found_it/features/chat/domain/use_cases/confirm_ownership_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_chat_match_details_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/get_signed_image_url_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/mark_messages_read_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/reject_chat_match_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/send_message_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/upload_chat_image_use_case.dart';
import 'package:found_it/features/chat/domain/use_cases/watch_messages_use_case.dart';
import 'package:found_it/features/chat/view/cubit/chat_badge_cubit.dart';
import 'package:found_it/features/chat/view/cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.getChatMatchDetailsUseCase,
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.uploadChatImageUseCase,
    required this.getSignedImageUrlUseCase,
    required this.markMessagesReadUseCase,
    required this.confirmOwnershipUseCase,
    required this.rejectChatMatchUseCase,
    this.chatBadgeCubit,
  }) : super(const ChatState());

  final GetChatMatchDetailsUseCase getChatMatchDetailsUseCase;
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final UploadChatImageUseCase uploadChatImageUseCase;
  final GetSignedImageUrlUseCase getSignedImageUrlUseCase;
  final MarkMessagesReadUseCase markMessagesReadUseCase;
  final ConfirmOwnershipUseCase confirmOwnershipUseCase;
  final RejectChatMatchUseCase rejectChatMatchUseCase;
  final ChatBadgeCubit? chatBadgeCubit;

  StreamSubscription<List<ChatMessageEntity>>? _messagesSub;
  String? _currentMatchId;
  bool _isReloadingDetails = false;

  /// In-memory cache for photo signed URLs (keyed by image_path).
  /// Fetches each signed URL only once and avoids refetching on stream updates.
  final Map<String, String> _signedUrlCache = {};

  Future<void> init(String matchId, {ChatItemEntity? initialChatInfo}) async {
    _currentMatchId = matchId;
    emit(state.copyWith(
      status: ChatStatus.loading,
      chatInfo: () => initialChatInfo,
      isConfirmed: initialChatInfo?.isVerified ?? false,
    ));

    // 1. Fetch fresh match details via RPC get_match_details(p_match_id)
    // Ensures brand-new chats (0 messages) immediately display the header and i_am_finder info.
    unawaited(_loadMatchDetails(matchId));

    // 2. Mark unread messages as read initially
    _markMessagesRead(matchId);

    // 3. Listen to realtime messages stream
    await _messagesSub?.cancel();
    _messagesSub = watchMessagesUseCase(matchId).listen(
      _handleIncomingMessages,
      onError: (err) {
        final failure = err is ChatFailure
            ? err
            : ChatFailure(ChatFailureType.unknown, err.toString());
        emit(state.copyWith(
          status: ChatStatus.failure,
          failure: () => failure,
        ));
      },
    );
  }

  Future<void> _loadMatchDetails(String matchId) async {
    try {
      final details = await getChatMatchDetailsUseCase(matchId);
      emit(state.copyWith(
        chatInfo: () => details,
        isConfirmed: details.isVerified,
      ));
    } catch (_) {
      // Keep existing initialChatInfo if offline or already loaded
    }
  }

  Future<void> _handleIncomingMessages(
    List<ChatMessageEntity> remoteMessages,
  ) async {
    // 1. Fetch signed URLs for any new photos not yet in cache
    final uncachedPaths = remoteMessages
        .where((m) =>
            m.imagePath != null &&
            m.imagePath!.isNotEmpty &&
            !_signedUrlCache.containsKey(m.imagePath))
        .map((m) => m.imagePath!)
        .toSet();

    for (final path in uncachedPaths) {
      try {
        final url = await getSignedImageUrlUseCase(path);
        if (url.isNotEmpty) {
          _signedUrlCache[path] = url;
        }
      } catch (_) {}
    }

    // 2. Hydrate messages with cached signed URLs
    final hydrated = remoteMessages.map((m) {
      if (m.imagePath != null && _signedUrlCache.containsKey(m.imagePath)) {
        return m.copyWith(imageUrl: _signedUrlCache[m.imagePath]);
      }
      return m;
    }).toList();

    emit(state.copyWith(
      status: ChatStatus.success,
      messages: hydrated,
    ));

    final matchId = _currentMatchId;

    // 3. The first message moves the match potential -> chatting on the server.
    // Reload the details so the finder's "Confirm Ownership" shows right away.
    if (matchId != null &&
        remoteMessages.isNotEmpty &&
        state.chatInfo?.status == 'potential' &&
        !_isReloadingDetails) {
      _isReloadingDetails = true;
      unawaited(
        _loadMatchDetails(matchId)
            .whenComplete(() => _isReloadingDetails = false),
      );
    }

    // 4. If any unread message arrived from the other user while the chat is open,
    // mark as read immediately so unread badge count stays accurate.
    final hasUnreadFromOther =
        remoteMessages.any((m) => !m.isMine && m.readAt == null);
    if (hasUnreadFromOther && matchId != null) {
      _markMessagesRead(matchId);
    }
  }

  void _markMessagesRead(String matchId) {
    unawaited(
      markMessagesReadUseCase(matchId).then((_) {
        chatBadgeCubit?.loadUnreadCount();
      }).catchError((_) {}),
    );
  }

  Future<void> sendMessage(String text) async {
    final matchId = _currentMatchId;
    final trimmed = text.trim();
    if (matchId == null || trimmed.isEmpty) return;

    final optimisticMessage = ChatMessageEntity(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      matchId: matchId,
      senderId: 'me',
      body: trimmed,
      createdAt: DateTime.now(),
      isMine: true,
      isSending: true,
      hasFailed: false,
    );

    final updated = List<ChatMessageEntity>.from(state.messages)
      ..add(optimisticMessage);
    emit(state.copyWith(messages: updated, isSending: true));

    try {
      await sendMessageUseCase(matchId, body: trimmed);
      final confirmed = state.messages.map((m) {
        if (m.id == optimisticMessage.id) {
          return m.copyWith(isSending: false);
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: confirmed, isSending: false));
    } catch (e) {
      final failure = e is ChatFailure
          ? e
          : ChatFailure(ChatFailureType.unknown, e.toString());
      final failed = state.messages.map((m) {
        if (m.id == optimisticMessage.id) {
          return m.copyWith(isSending: false, hasFailed: true);
        }
        return m;
      }).toList();
      emit(state.copyWith(
        messages: failed,
        isSending: false,
        failure: () => failure,
      ));
    }
  }

  Future<void> retryMessage(String messageId) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;

    final target = state.messages.where((m) => m.id == messageId).firstOrNull;
    if (target == null) return;

    // Set to sending and clear failed state
    final retrying = state.messages.map((m) {
      if (m.id == messageId) {
        return m.copyWith(isSending: true, hasFailed: false);
      }
      return m;
    }).toList();
    emit(state.copyWith(messages: retrying, isSending: true));

    try {
      await sendMessageUseCase(
        matchId,
        body: target.body,
        imagePath: target.imagePath,
      );
      final success = state.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(isSending: false, hasFailed: false);
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: success, isSending: false));
    } catch (e) {
      final failure = e is ChatFailure
          ? e
          : ChatFailure(ChatFailureType.unknown, e.toString());
      final failed = state.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(isSending: false, hasFailed: true);
        }
        return m;
      }).toList();
      emit(state.copyWith(
        messages: failed,
        isSending: false,
        failure: () => failure,
      ));
    }
  }

  Future<void> sendImage(Uint8List bytes, String extension) async {
    final matchId = _currentMatchId;
    if (matchId == null) return;

    final tempId = 'local_img_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = ChatMessageEntity(
      id: tempId,
      matchId: matchId,
      senderId: 'me',
      createdAt: DateTime.now(),
      isMine: true,
      isSending: true,
      hasFailed: false,
    );

    final updated = List<ChatMessageEntity>.from(state.messages)
      ..add(optimisticMessage);
    emit(state.copyWith(messages: updated, isSending: true));

    try {
      final path = await uploadChatImageUseCase(matchId, bytes, extension);
      final signedUrl = await getSignedImageUrlUseCase(path);
      _signedUrlCache[path] = signedUrl;

      await sendMessageUseCase(matchId, imagePath: path);

      final confirmed = state.messages.map((m) {
        if (m.id == tempId) {
          return m.copyWith(
            imagePath: path,
            imageUrl: signedUrl,
            isSending: false,
            hasFailed: false,
          );
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: confirmed, isSending: false));
    } catch (e) {
      final failure = e is ChatFailure
          ? e
          : ChatFailure(ChatFailureType.unknown, e.toString());
      final failed = state.messages.map((m) {
        if (m.id == tempId) {
          return m.copyWith(isSending: false, hasFailed: true);
        }
        return m;
      }).toList();
      emit(state.copyWith(
        messages: failed,
        isSending: false,
        failure: () => failure,
      ));
    }
  }

  Future<bool> confirmOwnership() async {
    final matchId = _currentMatchId;
    if (matchId == null) return false;

    emit(state.copyWith(isConfirming: true));
    try {
      await confirmOwnershipUseCase(matchId);
      emit(state.copyWith(
        isConfirming: false,
        isConfirmed: true,
      ));
      return true;
    } catch (e) {
      final failure = e is ChatFailure
          ? e
          : ChatFailure(ChatFailureType.unknown, e.toString());
      emit(state.copyWith(
        isConfirming: false,
        failure: () => failure,
      ));
      return false;
    }
  }

  Future<bool> rejectMatch() async {
    final matchId = _currentMatchId;
    if (matchId == null) return false;

    try {
      await rejectChatMatchUseCase(matchId);
      final updatedInfo = state.chatInfo?.copyWith(status: 'rejected');
      emit(state.copyWith(
        chatInfo: () => updatedInfo,
      ));
      return true;
    } catch (e) {
      final failure = e is ChatFailure
          ? e
          : ChatFailure(ChatFailureType.unknown, e.toString());
      emit(state.copyWith(
        failure: () => failure,
      ));
      return false;
    }
  }

  void clearFailure() {
    if (state.failure != null) {
      emit(state.copyWith(failure: () => null));
    }
  }

  /// Async work (signed URLs, sending, match details) can finish after the
  /// user left the chat. Emitting on a closed cubit throws, so ignore it.
  @override
  void emit(ChatState state) {
    if (isClosed) return;
    super.emit(state);
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
