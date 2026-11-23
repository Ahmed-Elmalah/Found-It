import 'package:equatable/equatable.dart';

import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/core/router/app_routes.dart';

/// One row from the `notifications` table (Section 8).
///
/// The title / body are NOT stored: they are built in the UI from these fields
/// and the current language (`.arb`).
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.createdAt,
    this.type,
    this.readAt,
    this.matchId,
    this.reportId,
    this.reportTitle,
    this.reportType,
    this.actorName,
    this.messagePreview,
  });

  final String id;
  final DateTime createdAt;

  /// Null for a type this app version doesn't know yet.
  final NotificationType? type;

  /// `read_at == null` means unread.
  final DateTime? readAt;

  final String? matchId;
  final String? reportId;

  /// **Your** report (title for the text).
  final String? reportTitle;

  /// `lost` / `found`.
  final String? reportType;

  /// Who did it; null for automatic matches.
  final String? actorName;

  /// First 80 chars of a chat message; null for photo-only messages.
  final String? messagePreview;

  bool get isRead => readAt != null;

  /// Deep link for this notification, built from [AppRoutes] helpers.
  ///
  /// Same mapping as the push payload (Section 8).
  String? get route {
    switch (type) {
      case NotificationType.potentialMatch:
        final id = matchId;
        return id == null ? null : AppRoutes.matchComparePath(id);
      case NotificationType.newMessage:
      case NotificationType.ownershipVerified:
      case NotificationType.matchRejected:
      case NotificationType.claimPassed:
        final id = matchId;
        return id == null ? null : AppRoutes.chatPath(id);
      case NotificationType.itemRecovered:
        final id = reportId;
        return id == null ? null : AppRoutes.reportDetailsPath(id);
      case null:
        return null;
    }
  }

  NotificationEntity copyWith({DateTime? readAt}) {
    return NotificationEntity(
      id: id,
      createdAt: createdAt,
      type: type,
      readAt: readAt ?? this.readAt,
      matchId: matchId,
      reportId: reportId,
      reportTitle: reportTitle,
      reportType: reportType,
      actorName: actorName,
      messagePreview: messagePreview,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    type,
    readAt,
    matchId,
    reportId,
    reportTitle,
    reportType,
    actorName,
    messagePreview,
  ];
}
