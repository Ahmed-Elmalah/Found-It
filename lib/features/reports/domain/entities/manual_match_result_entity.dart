import 'package:equatable/equatable.dart';

class ManualMatchResultEntity extends Equatable {
  final String matchId;
  final String status;
  final String claimStatus;
  final bool isNew;

  const ManualMatchResultEntity({
    required this.matchId,
    required this.status,
    required this.claimStatus,
    required this.isNew,
  });

  bool get isClaimPending => claimStatus == 'pending';

  @override
  List<Object?> get props => [matchId, status, claimStatus, isNew];
}
