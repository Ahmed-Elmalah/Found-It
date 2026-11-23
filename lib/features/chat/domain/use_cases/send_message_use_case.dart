import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this.repository);

  final ChatRepository repository;

  Future<void> call(
    String matchId, {
    String? body,
    String? imagePath,
  }) =>
      repository.sendMessage(matchId, body: body, imagePath: imagePath);
}
