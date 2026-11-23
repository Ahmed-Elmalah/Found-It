import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';

abstract interface class NotificationsRepository {
  /// Newest first, 50 rows (Section 8).
  Future<List<NotificationEntity>> getMyNotifications();

  /// [id] null = mark every notification as read.
  Future<void> markNotificationsRead({String? id});

  /// Supabase Realtime stream on the `notifications` table.
  Stream<List<NotificationEntity>> watchNotifications();
}
