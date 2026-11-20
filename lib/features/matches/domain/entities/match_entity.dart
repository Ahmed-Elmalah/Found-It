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
  });

  bool get isAuto => source == 'auto';
  bool get isOpen =>
      status == 'potential' || status == 'chatting' || status == 'verified';

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
      ];
}
