import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class GetSignedImageUrlUseCase {
  const GetSignedImageUrlUseCase(this.repository);

  final ChatRepository repository;

  Future<String> call(String path) => repository.getSignedImageUrl(path);
}
