import 'package:found_it/features/chat/domain/entities/chat_last_message_entity.dart';

class ChatLastMessageModel extends ChatLastMessageEntity {
  const ChatLastMessageModel({
    super.body,
    super.hasImage,
    super.isMine,
    super.createdAt,
  });

  factory ChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString());
    }

    return ChatLastMessageModel(
      body: json['body']?.toString(),
      hasImage: json['has_image'] == true,
      isMine: json['is_mine'] == true,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'body': body,
        'has_image': hasImage,
        'is_mine': isMine,
        'created_at': createdAt?.toIso8601String(),
      };
}
