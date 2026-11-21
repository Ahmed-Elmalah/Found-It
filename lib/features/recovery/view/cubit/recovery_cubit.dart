import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/core/events/reports_changed_notifier.dart';
import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';
import 'package:found_it/features/recovery/domain/use_cases/get_match_contact_use_case.dart';
import 'package:found_it/features/recovery/domain/use_cases/mark_item_recovered_use_case.dart';
import 'package:found_it/features/recovery/view/cubit/recovery_state.dart';

class RecoveryCubit extends Cubit<RecoveryState> {
  final GetMatchContactUseCase getMatchContact;
  final MarkItemRecoveredUseCase markItemRecovered;
  final ReportsChangedNotifier? reportsChangedNotifier;

  RecoveryCubit({
    required this.getMatchContact,
    required this.markItemRecovered,
    this.reportsChangedNotifier,
  }) : super(const RecoveryInitial());

  Future<void> loadContact(String matchId) async {
    emit(const RecoveryLoading());

    try {
      final contact = await getMatchContact(matchId);
      emit(HandoverContactLoaded(contact));
    } on RecoveryFailure catch (f) {
      emit(RecoveryError(f.type, f.message));
    } catch (_) {
      emit(const RecoveryError(RecoveryFailureType.unknown));
    }
  }

  Future<bool> confirmRecovery(String matchId) async {
    emit(const RecoverySubmitting());

    try {
      await markItemRecovered(matchId);
      reportsChangedNotifier?.notify();
      emit(const RecoverySuccess());
      return true;
    } on RecoveryFailure catch (f) {
      emit(RecoveryError(f.type, f.message));
      return false;
    } catch (_) {
      emit(const RecoveryError(RecoveryFailureType.unknown));
      return false;
    }
  }
}
