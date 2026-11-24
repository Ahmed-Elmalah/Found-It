import 'package:equatable/equatable.dart';

import 'package:found_it/features/chat/domain/entities/chat_failure.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.chatInfo,
    this.isSending = false,
    this.isConfirming = false,
    this.isConfirmed = false,
    this.failure,
  });

  final ChatStatus status;
  final List<ChatMessageEntity> messages;
  final ChatItemEntity? chatInfo;
  final bool isSending;
  final bool isConfirming;
  final bool isConfirmed;
  final ChatFailure? failure;

  bool get isFinder => chatInfo?.iAmFinder ?? false;
  bool get isVerified => isConfirmed || (chatInfo?.isVerified ?? false);
  bool get isClosed =>
      chatInfo?.status == 'rejected' || chatInfo?.status == 'recovered';

  /// User Story #6 (Ownership Verification Questions)
  bool get isClaimPending => chatInfo?.isClaimPending ?? false;
  bool get iMustAnswer => chatInfo?.iMustAnswer ?? false;

  /// UI rule from docs/api_sprint2.md (section 6 & 7):
  /// "Show it ONLY if i_am_finder == true and status == 'chatting'"
  /// and claim verification is not pending (User Story #6)
  bool get canConfirmOwnership =>
      (chatInfo?.iAmFinder ?? false) &&
      (chatInfo?.status == 'chatting') &&
      !isClaimPending &&
      !isVerified;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageEntity>? messages,
    ChatItemEntity? Function()? chatInfo,
    bool? isSending,
    bool? isConfirming,
    bool? isConfirmed,
    ChatFailure? Function()? failure,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatInfo: chatInfo != null ? chatInfo() : this.chatInfo,
      isSending: isSending ?? this.isSending,
      isConfirming: isConfirming ?? this.isConfirming,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        chatInfo,
        isSending,
        isConfirming,
        isConfirmed,
        failure,
      ];
}
