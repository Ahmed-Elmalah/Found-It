import 'package:equatable/equatable.dart';

import 'package:found_it/features/recovery/domain/entities/handover_contact_entity.dart';
import 'package:found_it/features/recovery/domain/entities/recovery_failure.dart';

sealed class RecoveryState extends Equatable {
  const RecoveryState();

  @override
  List<Object?> get props => [];
}

final class RecoveryInitial extends RecoveryState {
  const RecoveryInitial();
}

final class RecoveryLoading extends RecoveryState {
  const RecoveryLoading();
}

final class HandoverContactLoaded extends RecoveryState {
  final HandoverContactEntity contact;

  const HandoverContactLoaded(this.contact);

  @override
  List<Object?> get props => [contact];
}

final class RecoverySubmitting extends RecoveryState {
  const RecoverySubmitting();
}

final class RecoverySuccess extends RecoveryState {
  const RecoverySuccess();
}

final class RecoveryError extends RecoveryState {
  final RecoveryFailureType failureType;
  final String? message;

  const RecoveryError(this.failureType, [this.message]);

  @override
  List<Object?> get props => [failureType, message];
}
