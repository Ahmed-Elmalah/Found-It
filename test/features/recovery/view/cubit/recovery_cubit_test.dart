import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';
import 'package:found_it/features/recovery/domain/repositories/recovery_repository.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_cubit.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_state.dart';

class _FakeRecoveryRepository implements RecoveryRepository {
  bool shouldFailContact = false;
  bool shouldFailRecover = false;
  String? recoveredMatchId;

  final sampleContact = const HandoverContactEntity(
    fullName: 'Youssef Nabil',
    phone: '+20 11 2345 6789',
    email: 'youssef@example.com',
  );

  @override
  Future<HandoverContactEntity> getMatchContact(String matchId) async {
    if (shouldFailContact) {
      throw const RecoveryFailure(RecoveryFailureType.notVerified);
    }
    return sampleContact;
  }

  @override
  Future<void> markItemRecovered(String matchId) async {
    if (shouldFailRecover) {
      throw const RecoveryFailure(RecoveryFailureType.invalidState);
    }
    recoveredMatchId = matchId;
  }
}

void main() {
  group('RecoveryCubit Tests', () {
    late _FakeRecoveryRepository repo;
    late RecoveryCubit cubit;

    setUp(() {
      repo = _FakeRecoveryRepository();
      cubit = RecoveryCubit(
        getMatchContact: GetMatchContactUseCase(repo),
        markItemRecovered: MarkItemRecoveredUseCase(repo),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is RecoveryInitial', () {
      expect(cubit.state, const RecoveryInitial());
    });

    test('loadContact loads contact successfully into HandoverContactLoaded state',
        () async {
      await cubit.loadContact('match_123');

      expect(cubit.state, isA<HandoverContactLoaded>());
      final loaded = cubit.state as HandoverContactLoaded;
      expect(loaded.contact, repo.sampleContact);
    });

    test('loadContact emits RecoveryError on failure', () async {
      repo.shouldFailContact = true;

      await cubit.loadContact('match_123');

      expect(cubit.state, isA<RecoveryError>());
      final error = cubit.state as RecoveryError;
      expect(error.failureType, RecoveryFailureType.notVerified);
    });

    test('confirmRecovery marks item recovered and emits RecoverySuccess on success',
        () async {
      final result = await cubit.confirmRecovery('match_123');

      expect(result, isTrue);
      expect(repo.recoveredMatchId, 'match_123');
      expect(cubit.state, const RecoverySuccess());
    });

    test('confirmRecovery emits RecoveryError and returns false on failure',
        () async {
      repo.shouldFailRecover = true;

      final result = await cubit.confirmRecovery('match_123');

      expect(result, isFalse);
      expect(cubit.state, isA<RecoveryError>());
      final error = cubit.state as RecoveryError;
      expect(error.failureType, RecoveryFailureType.invalidState);
    });
  });
}
