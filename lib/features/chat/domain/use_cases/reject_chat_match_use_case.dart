import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class RejectChatMatchUseCase {
  const RejectChatMatchUseCase(this._repository);

  final ChatRepository _repository;

  Future<void> call(String matchId) => _repository.rejectMatch(matchId);
}
