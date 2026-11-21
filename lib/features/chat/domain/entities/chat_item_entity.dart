import 'package:equatable/equatable.dart';

import 'package:found_it/features/chat/domain/entities/chat_last_message_entity.dart';
import 'package:found_it/features/chat/domain/entities/chat_report_summary_entity.dart';

class ChatItemEntity extends Equatable {
  const ChatItemEntity({
    required this.matchId,
    required this.status,
    this.similarity = 0,
    this.source = 'auto',
    this.ownershipVerified = false,
    this.iAmFinder = false,
    required this.otherUserName,
    this.createdAt,
    this.lastMessageAt,
    this.myReport,
    this.otherReport,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String matchId;
  final String status; // 'potential', 'chatting', 'verified', 'recovered', 'rejected'
  final int similarity;
  final String source; // 'auto', 'manual'
  final bool ownershipVerified;
  final bool iAmFinder;
  final String otherUserName;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final ChatReportSummaryEntity? myReport;
  final ChatReportSummaryEntity? otherReport;
  final ChatLastMessageEntity? lastMessage;
  final int unreadCount;

  bool get isClosed => status == 'recovered' || status == 'rejected';
  bool get isVerified => status == 'verified' || ownershipVerified;

  /// P31 specification from docs/api_sprint2.md:
  /// Use the lost side:
  /// - my_report if i_am_finder == false
  /// - otherwise other_report
  /// - fallback to whichever is not null
  ChatReportSummaryEntity? get displayReport {
    if (!iAmFinder && myReport != null) return myReport;
    if (otherReport != null) return otherReport;
    return myReport;
  }

  @override
  List<Object?> get props => [
        matchId,
        status,
        similarity,
        source,
        ownershipVerified,
        iAmFinder,
        otherUserName,
        createdAt,
        lastMessageAt,
        myReport,
        otherReport,
        lastMessage,
        unreadCount,
      ];
}
