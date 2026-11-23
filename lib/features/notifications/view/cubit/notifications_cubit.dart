import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';
import 'package:found_it/features/notifications/domain/use_cases/get_my_notifications_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/mark_notifications_read_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/watch_notifications_use_case.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_state.dart';

/// The user's notifications list (P30) + the unread count used by the Home
/// bell.
///
/// App-wide singleton (see `injection.dart`) so the screen and the bell share
/// the same live state. Realtime is subscribed lazily by [loadNotifications]
/// and cancelled in [close].
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.getMyNotifications,
    required this.markNotificationsRead,
    required this.watchNotifications,
  }) : super(const NotificationsState());

  final GetMyNotificationsUseCase getMyNotifications;
  final MarkNotificationsReadUseCase markNotificationsRead;
  final WatchNotificationsUseCase watchNotifications;

  StreamSubscription<List<NotificationEntity>>? _realtimeSubscription;

  /// Loads the newest 50 rows (Section 8) and subscribes to Realtime.
  ///
  /// [showLoading] = false keeps the current list on screen (pull to refresh).
  Future<void> loadNotifications({bool showLoading = true}) async {
    _subscribeToRealtime();

    if (showLoading) {
      emit(
        state.copyWith(status: NotificationsStatus.loading, clearFailure: true),
      );
    }

    try {
      final notifications = await getMyNotifications();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: _sorted(notifications),
          clearFailure: true,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          failure: _toFailure(error),
        ),
      );
    }
  }

  /// Marks one notification read, optimistically. Returns false (and rolls the
  /// list back) when the server call fails.
  Future<bool> markAsRead(String id) async {
    final index = state.notifications.indexWhere((item) => item.id == id);
    if (index == -1) return true;

    final current = state.notifications[index];
    if (current.isRead) return true;

    final previous = state.notifications;
    emit(
      state.copyWith(
        notifications: _replaceReadAt(previous, index, DateTime.now()),
      ),
    );

    try {
      await markNotificationsRead(id: id);
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(notifications: previous, failure: _toFailure(error)),
        );
      }
      return false;
    }
  }

  /// "Mark all read" — `mark_notifications_read` with no params.
  ///
  /// Optimistic like [markAsRead]; returns false on failure.
  Future<bool> markAllAsRead() async {
    if (!state.hasUnread) return true;

    final previous = state.notifications;
    final readAt = DateTime.now();
    emit(
      state.copyWith(
        notifications: [
          for (final item in previous)
            item.isRead ? item : item.copyWith(readAt: readAt),
        ],
      ),
    );

    try {
      await markNotificationsRead();
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(notifications: previous, failure: _toFailure(error)),
        );
      }
      return false;
    }
  }

  /// Resets everything on logout (the bell dot must disappear) and stops the
  /// Realtime subscription, which no longer has a session to listen with.
  Future<void> clear() async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    if (!isClosed) emit(const NotificationsState());
  }

  void _subscribeToRealtime() {
    if (_realtimeSubscription != null) return;

    _realtimeSubscription = watchNotifications().listen(
      (notifications) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: _sorted(notifications),
            clearFailure: true,
          ),
        );
      },
      onError: (Object error) {
        if (isClosed) return;
        // A broken live connection must not wipe an already loaded list.
        emit(state.copyWith(failure: _toFailure(error)));
      },
    );
  }

  @override
  Future<void> close() async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
    return super.close();
  }

  static List<NotificationEntity> _sorted(
    List<NotificationEntity> notifications,
  ) {
    final copy = [...notifications];
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  static List<NotificationEntity> _replaceReadAt(
    List<NotificationEntity> notifications,
    int index,
    DateTime readAt,
  ) {
    return [
      for (var i = 0; i < notifications.length; i++)
        i == index
            ? notifications[i].copyWith(readAt: readAt)
            : notifications[i],
    ];
  }

  static NotificationsFailure _toFailure(Object error) {
    if (error is NotificationsFailure) return error;
    return const NotificationsFailure(NotificationsFailureType.unknown);
  }
}
