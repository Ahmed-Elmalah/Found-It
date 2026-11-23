import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.createdAt,
    super.type,
    super.readAt,
    super.matchId,
    super.reportId,
    super.reportTitle,
    super.reportType,
    super.actorName,
    super.messagePreview,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      type: NotificationType.fromRaw(json['type']?.toString()),
      readAt: _parseDate(json['read_at']),
      matchId: _readString(json['match_id']),
      reportId: _readString(json['report_id']),
      reportTitle: _readString(json['report_title']),
      reportType: _readString(json['report_type']),
      actorName: _readString(json['actor_name']),
      messagePreview: _readString(json['message_preview']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    return parsed?.toLocal();
  }

  static String? _readString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
