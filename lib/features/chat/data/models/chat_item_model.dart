import 'package:found_it/features/chat/data/models/chat_last_message_model.dart';
import 'package:found_it/features/chat/data/models/chat_report_summary_model.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

class ChatItemModel extends ChatItemEntity {
  const ChatItemModel({
    required super.matchId,
    required super.status,
    super.similarity,
    super.source,
    super.ownershipVerified,
    super.iAmFinder,
    required super.otherUserName,
    super.createdAt,
    super.lastMessageAt,
    super.myReport,
    super.otherReport,
    super.lastMessage,
    super.unreadCount,
  });

  factory ChatItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedCreatedAt;
    if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    DateTime? parsedLastMessageAt;
    if (json['last_message_at'] != null) {
      parsedLastMessageAt = DateTime.tryParse(json['last_message_at'].toString());
    }

    ChatReportSummaryModel? myReport;
    if (json['my_report'] is Map<String, dynamic>) {
      myReport = ChatReportSummaryModel.fromJson(json['my_report'] as Map<String, dynamic>);
    }

    ChatReportSummaryModel? otherReport;
    if (json['other_report'] is Map<String, dynamic>) {
      otherReport = ChatReportSummaryModel.fromJson(json['other_report'] as Map<String, dynamic>);
    }

    ChatLastMessageModel? lastMessage;
    if (json['last_message'] is Map<String, dynamic>) {
      lastMessage = ChatLastMessageModel.fromJson(json['last_message'] as Map<String, dynamic>);
    }

    final unread = json['unread_count'];
    final int parsedUnread = unread is int
        ? unread
        : int.tryParse(unread?.toString() ?? '0') ?? 0;

    final sim = json['similarity'];
    final int parsedSim = sim is int
        ? sim
        : int.tryParse(sim?.toString() ?? '0') ?? 0;

    return ChatItemModel(
      matchId: json['match_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'potential',
      similarity: parsedSim,
      source: json['source']?.toString() ?? 'auto',
      ownershipVerified: json['ownership_verified'] == true,
      iAmFinder: json['i_am_finder'] == true,
      otherUserName: json['other_user_name']?.toString() ?? 'Anonymous',
      createdAt: parsedCreatedAt,
      lastMessageAt: parsedLastMessageAt,
      myReport: myReport,
      otherReport: otherReport,
      lastMessage: lastMessage,
      unreadCount: parsedUnread,
    );
  }

  Map<String, dynamic> toJson() => {
        'match_id': matchId,
        'status': status,
        'similarity': similarity,
        'source': source,
        'ownership_verified': ownershipVerified,
        'i_am_finder': iAmFinder,
        'other_user_name': otherUserName,
        'created_at': createdAt?.toIso8601String(),
        'last_message_at': lastMessageAt?.toIso8601String(),
        'my_report': (myReport as ChatReportSummaryModel?)?.toJson(),
        'other_report': (otherReport as ChatReportSummaryModel?)?.toJson(),
        'last_message': (lastMessage as ChatLastMessageModel?)?.toJson(),
        'unread_count': unreadCount,
      };
}
