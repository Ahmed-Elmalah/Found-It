import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:found_it/features/notifications/domain/use_cases/get_my_notifications_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/mark_notifications_read_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/watch_notifications_use_case.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_cubit.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_state.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  final StreamController<List<NotificationEntity>> realtime =
      StreamController<List<NotificationEntity>>.broadcast();

  List<NotificationEntity> notifications = const [];
  Object? loadError;
  Object? markError;
  int loadCalls = 0;
  int watchCalls = 0;
  final List<String?> markedIds = [];

  @override
  Future<List<NotificationEntity>> getMyNotifications() async {
    loadCalls++;
    if (loadError != null) throw loadError!;
    return notifications;
  }

  @override
  Future<void> markNotificationsRead({String? id}) async {
    if (markError != null) throw markError!;
    markedIds.add(id);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    watchCalls++;
    return realtime.stream;
  }
}

NotificationEntity _notification({
  required String id,
  NotificationType? type = NotificationType.newMessage,
  DateTime? createdAt,
  DateTime? readAt,
  String? matchId,
  String? reportId,
  String? reportTitle,
  String? reportType,
  String? actorName,
  String? messagePreview,
}) {
  return NotificationEntity(
    id: id,
    createdAt: createdAt ?? DateTime.now(),
    type: type,
    readAt: readAt,
    matchId: matchId,
    reportId: reportId,
    reportTitle: reportTitle,
    reportType: reportType,
    actorName: actorName,
    messagePreview: messagePreview,
  );
}

void main() {
  late _FakeNotificationsRepository repository;
  late NotificationsCubit cubit;

  setUp(() {
    repository = _FakeNotificationsRepository();
    cubit = NotificationsCubit(
      getMyNotifications: GetMyNotificationsUseCase(repository),
      markNotificationsRead: MarkNotificationsReadUseCase(repository),
      watchNotifications: WatchNotificationsUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.realtime.close();
  });

  group('loadNotifications', () {
    test('starts with an empty initial state', () {
      expect(cubit.state.status, NotificationsStatus.initial);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.hasUnread, isFalse);
    });

    test(
      'emits loading then success with newest first and Today/Earlier groups',
      () async {
        final now = DateTime.now();
        final todayNoon = DateTime(now.year, now.month, now.day, 12);
        final today = _notification(
          id: 'n-today',
          createdAt: todayNoon.subtract(const Duration(hours: 1)),
        );
        final earlier = _notification(
          id: 'n-earlier',
          createdAt: todayNoon.subtract(const Duration(days: 3)),
        );
        repository.notifications = [earlier, today];

        final statuses = cubit.stream
            .map((state) => state.status)
            .take(2)
            .toList();

        await cubit.loadNotifications();

        expect(await statuses, [
          NotificationsStatus.loading,
          NotificationsStatus.success,
        ]);
        expect(cubit.state.notifications.map((n) => n.id), [
          'n-today',
          'n-earlier',
        ]);
        expect(cubit.state.groupedToday(now).map((n) => n.id), ['n-today']);
        expect(cubit.state.groupedEarlier(now).map((n) => n.id), ['n-earlier']);
        expect(cubit.state.unreadCount, 2);
        expect(cubit.state.isEmpty, isFalse);
        expect(repository.watchCalls, 1);
      },
    );

    test('reports an empty success state', () async {
      await cubit.loadNotifications();

      expect(cubit.state.status, NotificationsStatus.success);
      expect(cubit.state.isEmpty, isTrue);
      expect(cubit.state.hasUnread, isFalse);
    });

    test('maps a typed failure and keeps it for the error state', () async {
      repository.loadError = const NotificationsFailure(
        NotificationsFailureType.network,
      );

      await cubit.loadNotifications();

      expect(cubit.state.status, NotificationsStatus.failure);
      expect(cubit.state.failure?.type, NotificationsFailureType.network);
      expect(cubit.state.notifications, isEmpty);
    });

    test(
      'wraps unexpected errors as unknown (never exposes the message)',
      () async {
        repository.loadError = Exception('secret backend detail');

        await cubit.loadNotifications();

        expect(cubit.state.failure?.type, NotificationsFailureType.unknown);
        expect(cubit.state.failure?.code, isNull);
      },
    );

    test('subscribes to Realtime only once', () async {
      await cubit.loadNotifications();
      await cubit.loadNotifications();

      expect(repository.watchCalls, 1);
    });
  });

  group('markAsRead', () {
    test(
      'marks the row read optimistically and calls the RPC with its id',
      () async {
        repository.notifications = [_notification(id: 'n1', matchId: 'm1')];
        await cubit.loadNotifications();

        final result = cubit.markAsRead('n1');

        // Optimistic update happens before the network call completes.
        expect(cubit.state.unreadCount, 0);
        expect(cubit.state.notifications.single.isRead, isTrue);

        expect(await result, isTrue);
        expect(repository.markedIds, ['n1']);
      },
    );

    test('rolls back when the RPC fails', () async {
      repository.notifications = [_notification(id: 'n1')];
      await cubit.loadNotifications();
      repository.markError = const NotificationsFailure(
        NotificationsFailureType.server,
      );

      final result = await cubit.markAsRead('n1');

      expect(result, isFalse);
      expect(cubit.state.unreadCount, 1);
      expect(cubit.state.notifications.single.isRead, isFalse);
      expect(cubit.state.failure?.type, NotificationsFailureType.server);
    });

    test('is a no-op for an already read row', () async {
      repository.notifications = [
        _notification(id: 'n1', readAt: DateTime.now()),
      ];
      await cubit.loadNotifications();

      expect(await cubit.markAsRead('n1'), isTrue);
      expect(repository.markedIds, isEmpty);
    });

    test('is a no-op for an unknown id', () async {
      await cubit.loadNotifications();

      expect(await cubit.markAsRead('missing'), isTrue);
      expect(repository.markedIds, isEmpty);
    });
  });

  group('markAllAsRead', () {
    test('marks every unread row and calls the RPC without params', () async {
      repository.notifications = [
        _notification(id: 'n1'),
        _notification(id: 'n2'),
        _notification(id: 'n3', readAt: DateTime.now()),
      ];
      await cubit.loadNotifications();

      expect(await cubit.markAllAsRead(), isTrue);

      expect(repository.markedIds, [null]);
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.notifications.every((n) => n.isRead), isTrue);
    });

    test('rolls back every row when the RPC fails', () async {
      repository.notifications = [
        _notification(id: 'n1'),
        _notification(id: 'n2'),
      ];
      await cubit.loadNotifications();
      repository.markError = const NotificationsFailure(
        NotificationsFailureType.network,
      );

      expect(await cubit.markAllAsRead(), isFalse);

      expect(cubit.state.unreadCount, 2);
      expect(repository.markedIds, isEmpty);
    });

    test('does nothing when there is nothing unread', () async {
      repository.notifications = [
        _notification(id: 'n1', readAt: DateTime.now()),
      ];
      await cubit.loadNotifications();

      expect(await cubit.markAllAsRead(), isTrue);
      expect(repository.markedIds, isEmpty);
    });
  });

  group('Realtime', () {
    test(
      'a stream emission replaces the list and updates the unread count',
      () async {
        repository.notifications = [_notification(id: 'n1')];
        await cubit.loadNotifications();

        final next = cubit.stream.firstWhere(
          (state) => state.notifications.any((n) => n.id == 'n2'),
        );
        repository.realtime.add([
          _notification(id: 'n2', createdAt: DateTime.now()),
          _notification(id: 'n1', readAt: DateTime.now()),
        ]);
        await next;

        expect(cubit.state.notifications.map((n) => n.id), ['n2', 'n1']);
        expect(cubit.state.unreadCount, 1);
      },
    );

    test(
      'a stream error keeps the loaded rows and exposes the failure',
      () async {
        repository.notifications = [_notification(id: 'n1')];
        await cubit.loadNotifications();

        final failed = cubit.stream.firstWhere(
          (state) => state.failure != null,
        );
        repository.realtime.addError(
          const NotificationsFailure(NotificationsFailureType.server),
        );
        await failed;

        expect(cubit.state.notifications.single.id, 'n1');
        expect(cubit.state.failure?.type, NotificationsFailureType.server);
      },
    );

    test('close cancels the Realtime subscription', () async {
      await cubit.loadNotifications();
      expect(repository.realtime.hasListener, isTrue);

      await cubit.close();

      expect(repository.realtime.hasListener, isFalse);
    });
  });

  group('clear', () {
    test('resets the state and stops listening (logout)', () async {
      repository.notifications = [_notification(id: 'n1')];
      await cubit.loadNotifications();

      await cubit.clear();

      expect(cubit.state.status, NotificationsStatus.initial);
      expect(cubit.state.notifications, isEmpty);
      expect(cubit.state.unreadCount, 0);
      expect(repository.realtime.hasListener, isFalse);
    });

    test('loads again after a clear', () async {
      repository.notifications = [_notification(id: 'n1')];
      await cubit.loadNotifications();
      await cubit.clear();

      await cubit.loadNotifications();

      expect(cubit.state.status, NotificationsStatus.success);
      expect(repository.watchCalls, 2);
    });
  });
}
