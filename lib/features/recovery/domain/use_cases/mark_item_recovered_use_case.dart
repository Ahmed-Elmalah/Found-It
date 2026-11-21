import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';

class MarkItemRecoveredUseCase {
  final RecoveryRepository repository;

  const MarkItemRecoveredUseCase(this.repository);

  Future<void> call(String matchId) =>
      repository.markItemRecovered(matchId);
}
