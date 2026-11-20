import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';

class GetMatchContactUseCase {
  final RecoveryRepository repository;

  const GetMatchContactUseCase(this.repository);

  Future<HandoverContactEntity> call(String matchId) =>
      repository.getMatchContact(matchId);
}
