import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class GetUnreadMessagesCountUseCase {
  const GetUnreadMessagesCountUseCase(this._repository);

  final ChatRepository _repository;

  Future<int> call() => _repository.getUnreadMessagesCount();
}
