import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.matchId,
    required this.senderId,
    this.body,
    this.imagePath,
    this.imageUrl,
    this.readAt,
    required this.createdAt,
    this.isMine = false,
    this.isSending = false,
    this.hasFailed = false,
  });

  final String id;
  final String matchId;
  final String senderId;
  final String? body;
  final String? imagePath;
  final String? imageUrl;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool isMine;
  final bool isSending;
  final bool hasFailed;

  bool get isRead => readAt != null;
  bool get hasImage => (imagePath != null && imagePath!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty);

  ChatMessageEntity copyWith({
    String? id,
    String? matchId,
    String? senderId,
    String? body,
    String? imagePath,
    String? imageUrl,
    DateTime? readAt,
    DateTime? createdAt,
    bool? isMine,
    bool? isSending,
    bool? hasFailed,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      isSending: isSending ?? this.isSending,
      hasFailed: hasFailed ?? this.hasFailed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        matchId,
        senderId,
        body,
        imagePath,
        imageUrl,
        readAt,
        createdAt,
        isMine,
        isSending,
        hasFailed,
      ];
}
