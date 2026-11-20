import 'package:found_it/features/matches/data/models/match_report_summary_model.dart';
import 'package:found_it/features/matches/domain/entities/match_entity.dart';

class MatchModel extends MatchEntity {
  const MatchModel({
    required super.matchId,
    required super.status,
    required super.similarity,
    required super.source,
    required super.ownershipVerified,
    required super.iAmFinder,
    required super.createdAt,
    super.lastMessageAt,
    super.myReport,
    super.otherReport,
    required super.otherUserName,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final rawCreated = json['created_at'];
    if (rawCreated is DateTime) {
      createdAt = rawCreated;
    } else if (rawCreated is String && rawCreated.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    DateTime? lastMessageAt;
    final rawLast = json['last_message_at'];
    if (rawLast is DateTime) {
      lastMessageAt = rawLast;
    } else if (rawLast is String && rawLast.isNotEmpty) {
      lastMessageAt = DateTime.tryParse(rawLast);
    }

    final rawMyReport = json['my_report'];
    final myReport = (rawMyReport is Map<String, dynamic>)
        ? MatchReportSummaryModel.fromJson(rawMyReport)
        : null;

    final rawOtherReport = json['other_report'];
    final otherReport = (rawOtherReport is Map<String, dynamic>)
        ? MatchReportSummaryModel.fromJson(rawOtherReport)
        : null;

    final rawSim = json['similarity'];
    final int similarity = (rawSim is num) ? rawSim.toInt() : 0;

    return MatchModel(
      matchId: json['match_id'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'potential',
      similarity: similarity,
      source: json['source'] as String? ?? 'auto',
      ownershipVerified: json['ownership_verified'] as bool? ?? false,
      iAmFinder: json['i_am_finder'] as bool? ?? false,
      createdAt: createdAt,
      lastMessageAt: lastMessageAt,
      myReport: myReport,
      otherReport: otherReport,
      otherUserName: json['other_user_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'match_id': matchId,
        'status': status,
        'similarity': similarity,
        'source': source,
        'ownership_verified': ownershipVerified,
        'i_am_finder': iAmFinder,
        'created_at': createdAt.toIso8601String(),
        if (lastMessageAt != null)
          'last_message_at': lastMessageAt!.toIso8601String(),
        if (myReport != null)
          'my_report': (myReport as MatchReportSummaryModel).toJson(),
        if (otherReport != null)
          'other_report': (otherReport as MatchReportSummaryModel).toJson(),
        'other_user_name': otherUserName,
      };
}
