import 'package:equatable/equatable.dart';

class ChatLastMessageEntity extends Equatable {
  const ChatLastMessageEntity({
    this.body,
    this.hasImage = false,
    this.isMine = false,
    this.createdAt,
  });

  final String? body;
  final bool hasImage;
  final bool isMine;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [body, hasImage, isMine, createdAt];
}
