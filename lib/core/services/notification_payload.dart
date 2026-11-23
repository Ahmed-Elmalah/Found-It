import 'dart:convert';

import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/core/router/app_routes.dart';

export 'package:found_it/core/models/notification_type.dart';

/// One push notification, parsed from the FCM `data` map.
///
/// `data` shape (Section 8):
/// ```json
/// {
///   "type": "potential_match",
///   "notification_id": "uuid",
///   "match_id": "uuid",
///   "report_id": "uuid"
/// }
/// ```
class NotificationPayload {
  const NotificationPayload({
    required this.type,
    this.notificationId,
    this.matchId,
    this.reportId,
  });

  final NotificationType type;

  /// `notifications.id` — used by `mark_notifications_read`.
  final String? notificationId;

  /// The match this notification is about (match / chat types).
  final String? matchId;

  /// The user's own report (recovery type).
  final String? reportId;

  /// Parses an FCM `data` map.
  ///
  /// Throws [FormatException] when `type` is missing or unknown — use
  /// [tryParse] when the payload comes from outside the app.
  factory NotificationPayload.fromData(Map<String, dynamic> data) {
    final type = NotificationType.fromRaw(data['type']?.toString());
    if (type == null) {
      throw FormatException(
        'Unknown notification type: ${data['type']}',
        data.toString(),
      );
    }
    return NotificationPayload(
      type: type,
      notificationId: _readId(data, 'notification_id'),
      matchId: _readId(data, 'match_id'),
      reportId: _readId(data, 'report_id'),
    );
  }

  /// Like [fromData] but returns null instead of throwing.
  static NotificationPayload? tryParse(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return NotificationPayload.fromData(data);
    } on FormatException {
      return null;
    }
  }

  /// Parses the JSON-encoded `data` map stored on a local notification.
  static NotificationPayload? tryParseJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return tryParse(decoded.cast<String, dynamic>());
    } on FormatException {
      return null;
    }
  }

  /// Deep link for this notification, built from [AppRoutes] helpers.
  ///
  /// Returns null when the id required by [type] is missing, so a broken
  /// payload never navigates somewhere random.
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
    }
  }

  /// The `data` map, used as the local-notification payload.
  Map<String, dynamic> toData() => {
    'type': type.raw,
    if (notificationId != null) 'notification_id': notificationId,
    if (matchId != null) 'match_id': matchId,
    if (reportId != null) 'report_id': reportId,
  };

  String toJsonString() => jsonEncode(toData());

  static String? _readId(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    final id = value.toString().trim();
    return id.isEmpty ? null : id;
  }
}
