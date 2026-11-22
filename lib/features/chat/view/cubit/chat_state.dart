import 'package:equatable/equatable.dart';

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
    this.errorMessage,
  });

  final ChatStatus status;
  final List<ChatMessageEntity> messages;
  final ChatItemEntity? chatInfo;
  final bool isSending;
  final bool isConfirming;
  final bool isConfirmed;
  final String? errorMessage;

  bool get isFinder => chatInfo?.iAmFinder ?? false;
  bool get isVerified => isConfirmed || (chatInfo?.isVerified ?? false);
  bool get isClosed =>
      chatInfo?.status == 'rejected' || chatInfo?.status == 'recovered';

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageEntity>? messages,
    ChatItemEntity? Function()? chatInfo,
    bool? isSending,
    bool? isConfirming,
    bool? isConfirmed,
    String? Function()? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      chatInfo: chatInfo != null ? chatInfo() : this.chatInfo,
      isSending: isSending ?? this.isSending,
      isConfirming: isConfirming ?? this.isConfirming,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
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
        errorMessage,
      ];
}
