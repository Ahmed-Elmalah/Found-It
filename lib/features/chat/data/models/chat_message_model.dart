import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.matchId,
    required super.senderId,
    super.body,
    super.imagePath,
    super.imageUrl,
    super.readAt,
    required super.createdAt,
    super.isMine = false,
    super.isSending = false,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
    String? signedImageUrl,
  }) {
    final senderId = json['sender_id'] as String? ?? '';
    final createdAtStr = json['created_at'] as String?;
    final readAtStr = json['read_at'] as String?;

    return ChatMessageModel(
      id: json['id'] as String? ?? '',
      matchId: json['match_id'] as String? ?? '',
      senderId: senderId,
      body: json['body'] as String?,
      imagePath: json['image_path'] as String?,
      imageUrl: signedImageUrl ?? json['image_url'] as String?,
      readAt: readAtStr != null ? DateTime.tryParse(readAtStr) : null,
      createdAt: createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now(),
      isMine: currentUserId != null && senderId == currentUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'match_id': matchId,
        'sender_id': senderId,
        if (body != null) 'body': body,
        if (imagePath != null) 'image_path': imagePath,
        if (readAt != null) 'read_at': readAt!.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
