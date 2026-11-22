import 'dart:convert';

import 'package:found_it/core/router/app_routes.dart';

/// Notification types sent in the push `data.type` field.
///
/// Source of truth: `docs/api_sprint2.md` Section 8 ("Push payload").
enum NotificationType {
  potentialMatch('potential_match'),
  newMessage('new_message'),
  ownershipVerified('ownership_verified'),
  matchRejected('match_rejected'),
  itemRecovered('item_recovered'),
  claimPassed('claim_passed');

  const NotificationType(this.raw);

  /// The value used by the backend / Edge Function.
  final String raw;

  /// Maps a raw `data.type` to a [NotificationType], or null when unknown.
  ///
  /// The short aliases (`match`, `message`, `recovered`) are accepted too so a
  /// typo on the backend side degrades gracefully instead of dropping the tap.
  static NotificationType? fromRaw(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'potential_match':
      case 'match':
        return NotificationType.potentialMatch;
      case 'new_message':
      case 'message':
        return NotificationType.newMessage;
      case 'ownership_verified':
        return NotificationType.ownershipVerified;
      case 'match_rejected':
        return NotificationType.matchRejected;
      case 'item_recovered':
      case 'recovered':
        return NotificationType.itemRecovered;
      case 'claim_passed':
        return NotificationType.claimPassed;
      default:
        return null;
    }
  }
}

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
