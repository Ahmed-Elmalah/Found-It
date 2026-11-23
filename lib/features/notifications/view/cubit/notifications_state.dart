import 'package:equatable/equatable.dart';

import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.failure,
  });

  final NotificationsStatus status;

  /// Newest first.
  final List<NotificationEntity> notifications;

  final NotificationsFailure? failure;

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  bool get hasUnread => unreadCount > 0;

  bool get isEmpty =>
      status == NotificationsStatus.success && notifications.isEmpty;

  /// Notifications created on [now]'s local day ("Today" section).
  List<NotificationEntity> groupedToday(DateTime now) =>
      notifications.where((item) => _isSameDay(item.createdAt, now)).toList();

  /// Everything older than [now]'s local day ("Earlier" section).
  List<NotificationEntity> groupedEarlier(DateTime now) =>
      notifications.where((item) => !_isSameDay(item.createdAt, now)).toList();

  List<NotificationEntity> get today => groupedToday(DateTime.now());

  List<NotificationEntity> get earlier => groupedEarlier(DateTime.now());

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    NotificationsFailure? failure,
    bool clearFailure = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  @override
  List<Object?> get props => [status, notifications, failure];
}
