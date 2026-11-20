import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_state.dart';

class RecoveryCubit extends Cubit<RecoveryState> {
  final GetMatchContactUseCase getMatchContact;
  final MarkItemRecoveredUseCase markItemRecovered;

  RecoveryCubit({
    required this.getMatchContact,
    required this.markItemRecovered,
  }) : super(const RecoveryInitial());

  Future<void> loadContact(String matchId) async {
    emit(const RecoveryLoading());

    try {
      final contact = await getMatchContact(matchId);
      emit(HandoverContactLoaded(contact));
    } on RecoveryFailure catch (f) {
      emit(RecoveryError(f.type, f.message));
    } catch (e) {
      emit(RecoveryError(RecoveryFailureType.unknown, e.toString()));
    }
  }

  Future<bool> confirmRecovery(String matchId) async {
    emit(const RecoverySubmitting());

    try {
      await markItemRecovered(matchId);
      emit(const RecoverySuccess());
      return true;
    } on RecoveryFailure catch (f) {
      emit(RecoveryError(f.type, f.message));
      return false;
    } catch (e) {
      emit(RecoveryError(RecoveryFailureType.unknown, e.toString()));
      return false;
    }
  }
}
