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
    this.otherUserAvatar,
    this.createdAt,
    this.lastMessageAt,
    this.myReport,
    this.otherReport,
    this.lastMessage,
    this.unreadCount = 0,
    this.claimStatus = 'not_required',
    this.iMustAnswer = false,
  });

  final String matchId;
  final String status; // 'potential', 'chatting', 'verified', 'recovered', 'rejected'
  final int similarity;
  final String source; // 'auto', 'manual'
  final bool ownershipVerified;
  final bool iAmFinder;
  final String otherUserName;
  final String? otherUserAvatar;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final ChatReportSummaryEntity? myReport;
  final ChatReportSummaryEntity? otherReport;
  final ChatLastMessageEntity? lastMessage;
  final int unreadCount;

  /// User Story #6 (Ownership Verification Questions)
  /// Values: 'not_required' | 'pending' | 'passed' | 'failed'
  final String claimStatus;

  /// True if the current user is the claimant who must answer before chatting
  final bool iMustAnswer;

  bool get isClosed => status == 'recovered' || status == 'rejected';
  bool get isVerified => status == 'verified' || ownershipVerified;
  bool get isClaimPending => claimStatus == 'pending';

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

  ChatItemEntity copyWith({
    String? matchId,
    String? status,
    int? similarity,
    String? source,
    bool? ownershipVerified,
    bool? iAmFinder,
    String? otherUserName,
    String? otherUserAvatar,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    ChatReportSummaryEntity? myReport,
    ChatReportSummaryEntity? otherReport,
    ChatLastMessageEntity? lastMessage,
    int? unreadCount,
    String? claimStatus,
    bool? iMustAnswer,
  }) {
    return ChatItemEntity(
      matchId: matchId ?? this.matchId,
      status: status ?? this.status,
      similarity: similarity ?? this.similarity,
      source: source ?? this.source,
      ownershipVerified: ownershipVerified ?? this.ownershipVerified,
      iAmFinder: iAmFinder ?? this.iAmFinder,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      myReport: myReport ?? this.myReport,
      otherReport: otherReport ?? this.otherReport,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      claimStatus: claimStatus ?? this.claimStatus,
      iMustAnswer: iMustAnswer ?? this.iMustAnswer,
    );
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
        otherUserAvatar,
        createdAt,
        lastMessageAt,
        myReport,
        otherReport,
        lastMessage,
        unreadCount,
        claimStatus,
        iMustAnswer,
      ];
}
