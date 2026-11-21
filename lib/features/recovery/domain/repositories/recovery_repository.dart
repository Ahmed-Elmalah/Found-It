import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';

abstract class RecoveryRepository {
  Future<HandoverContactEntity> getMatchContact(String matchId);
  Future<void> markItemRecovered(String matchId);
}
