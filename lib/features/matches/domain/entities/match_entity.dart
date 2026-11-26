import 'package:equatable/equatable.dart';

import 'package:found_it/features/matches/domain/entities/match_report_summary.dart';

class MatchEntity extends Equatable {
  final String matchId;
  final String status; // 'potential' | 'chatting' | 'verified' | 'recovered' | 'rejected'
  final int similarity; // 0..100
  final String source; // 'auto' | 'manual'
  final bool ownershipVerified;
  final bool iAmFinder;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final MatchReportSummary? myReport;
  final MatchReportSummary? otherReport;
  final String otherUserName;

  /// Story #6 (Ownership Verification Questions):
  /// 'not_required' | 'pending' | 'passed' | 'failed'
  final String claimStatus;

  /// True when the current user (lost side) must answer questions before chatting.
  final bool iMustAnswer;

  /// Number of verification questions on the matched found report (0..3).
  final int questionsCount;

  const MatchEntity({
    required this.matchId,
    required this.status,
    required this.similarity,
    required this.source,
    required this.ownershipVerified,
    required this.iAmFinder,
    required this.createdAt,
    this.lastMessageAt,
    this.myReport,
    this.otherReport,
    required this.otherUserName,
    this.claimStatus = 'not_required',
    this.iMustAnswer = false,
    this.questionsCount = 0,
  });

  bool get isAuto => source == 'auto';
  bool get isOpen =>
      status == 'potential' || status == 'chatting' || status == 'verified';
  bool get isClaimPending => claimStatus == 'pending';

  @override
  List<Object?> get props => [
        matchId,
        status,
        similarity,
        source,
        ownershipVerified,
        iAmFinder,
        createdAt,
        lastMessageAt,
        myReport,
        otherReport,
        otherUserName,
        claimStatus,
        iMustAnswer,
        questionsCount,
      ];
}
