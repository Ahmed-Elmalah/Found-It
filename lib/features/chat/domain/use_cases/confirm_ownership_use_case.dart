import 'package:found_it/features/chat/domain/repositories/chat_repository.dart';

class ConfirmOwnershipUseCase {
  const ConfirmOwnershipUseCase(this.repository);

  final ChatRepository repository;

  Future<void> call(String matchId) => repository.confirmOwnership(matchId);
}
