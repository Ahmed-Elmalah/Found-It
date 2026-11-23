import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class UploadChatImageUseCase {
  const UploadChatImageUseCase(this.repository);

  final ChatRepository repository;

  Future<String> call(
    String matchId,
    List<int> bytes,
    String extension,
  ) =>
      repository.uploadChatImage(matchId, bytes, extension);
}
