import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:found_it/features/notifications/domain/use_cases/get_my_notifications_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/mark_notifications_read_use_case.dart';
import 'package:found_it/features/notifications/domain/use_cases/watch_notifications_use_case.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_cubit.dart';
import 'package:found_it/features/notifications/view/ui/notifications_screen.dart';

import '../../../../helpers/test_app.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  final StreamController<List<NotificationEntity>> realtime =
      StreamController<List<NotificationEntity>>.broadcast();

  List<NotificationEntity> notifications = const [];
  Object? loadError;
  Object? markError;
  final List<String?> markedIds = [];

  @override
  Future<List<NotificationEntity>> getMyNotifications() async {
    if (loadError != null) throw loadError!;
    return notifications;
  }

  @override
  Future<void> markNotificationsRead({String? id}) async {
    if (markError != null) throw markError!;
    markedIds.add(id);
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() => realtime.stream;
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

class _Harness {
  _Harness({
    List<NotificationEntity> notifications = const [],
    Object? loadError,
  }) : repository = _FakeNotificationsRepository() {
    repository.notifications = notifications;
    repository.loadError = loadError;
    cubit = NotificationsCubit(
      getMyNotifications: GetMyNotificationsUseCase(repository),
      markNotificationsRead: MarkNotificationsReadUseCase(repository),
      watchNotifications: WatchNotificationsUseCase(repository),
    );
  }

  final _FakeNotificationsRepository repository;
  late final NotificationsCubit cubit;

  Future<void> load() => cubit.loadNotifications();

  Future<void> dispose() async {
    await cubit.close();
    await repository.realtime.close();
  }
}

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    NotificationsCubit cubit, {
    bool dark = false,
    bool rtl = false,
  }) {
    return pumpTestApp(
      tester,
      BlocProvider<NotificationsCubit>.value(
        value: cubit,
        child: const NotificationsScreen(),
      ),
      dark: dark,
      rtl: rtl,
      padded: false,
    );
  }

  GoRouter buildRouter(NotificationsCubit cubit) {
    return GoRouter(
      initialLocation: AppRoutes.notifications,
      routes: [
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => BlocProvider<NotificationsCubit>.value(
            value: cubit,
            child: const NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/matches/:id',
          builder: (context, state) =>
              Scaffold(body: Text('MATCH ${state.pathParameters['id']}')),
        ),
        GoRoute(
          path: '/chat/:matchId',
          builder: (context, state) =>
              Scaffold(body: Text('CHAT ${state.pathParameters['matchId']}')),
        ),
        GoRoute(
          path: '/reports/:id',
          builder: (context, state) =>
              Scaffold(body: Text('REPORT ${state.pathParameters['id']}')),
        ),
      ],
    );
  }

  testWidgets('groups notifications into Today and Earlier', (tester) async {
    final harness = _Harness(
      notifications: [
        _notification(
          id: 'n-today',
          type: NotificationType.potentialMatch,
          createdAt: DateTime.now(),
          matchId: 'm1',
          reportTitle: 'Black wallet',
          reportType: 'lost',
        ),
        _notification(
          id: 'n-earlier',
          type: NotificationType.newMessage,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          matchId: 'm2',
          actorName: 'Mona K.',
          messagePreview: 'Is this yours?',
        ),
      ],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('Potential match found'), findsOneWidget);
    expect(find.textContaining('Black wallet'), findsOneWidget);
    expect(find.text('New message from Mona K.'), findsOneWidget);
    expect(find.text('Is this yours?'), findsOneWidget);
  });

  testWidgets('renders unread and read styling in light theme', (tester) async {
    final harness = _Harness(
      notifications: [
        _notification(id: 'unread'),
        _notification(id: 'read', readAt: DateTime.now()),
      ],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NotificationsScreen));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(
      find.byKey(const ValueKey('notification_unread_dot_unread')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('notification_unread_dot_read')),
      findsNothing,
    );
  });

  testWidgets('renders in dark theme with unread styling', (tester) async {
    final harness = _Harness(
      notifications: [
        _notification(
          id: 'n1',
          type: NotificationType.ownershipVerified,
          actorName: 'Mona K.',
        ),
        _notification(
          id: 'n2',
          type: NotificationType.itemRecovered,
          reportTitle: 'iPhone 13',
          readAt: DateTime.now(),
        ),
      ],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit, dark: true);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(NotificationsScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Ownership verified'), findsOneWidget);
    expect(find.text('Report recovered'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('notification_unread_dot_n1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('notification_unread_dot_n2')),
      findsNothing,
    );
  });

  testWidgets('renders Arabic section headers in RTL', (tester) async {
    final harness = _Harness(
      notifications: [_notification(id: 'n1', createdAt: DateTime.now())],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit, rtl: true);
    await tester.pumpAndSettle();

    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('تحديد الكل كمقروء'), findsOneWidget);
  });

  testWidgets('mark all read calls the RPC and hides the action', (
    tester,
  ) async {
    final harness = _Harness(
      notifications: [
        _notification(id: 'n1'),
        _notification(id: 'n2', readAt: DateTime.now()),
      ],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('notifications_mark_all_read')));
    await tester.pumpAndSettle();

    expect(harness.repository.markedIds, [null]);
    expect(harness.cubit.state.unreadCount, 0);
    expect(find.text('Mark all read'), findsNothing);
    expect(
      find.byKey(const ValueKey('notification_unread_dot_n1')),
      findsNothing,
    );
  });

  testWidgets('mark all read is hidden when everything is already read', (
    tester,
  ) async {
    final harness = _Harness(
      notifications: [_notification(id: 'n1', readAt: DateTime.now())],
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('notifications_mark_all_read')),
      findsNothing,
    );
  });

  for (final testCase in [
    (
      type: NotificationType.potentialMatch,
      entity: _notification(
        id: 'n1',
        type: NotificationType.potentialMatch,
        matchId: 'm1',
      ),
      expected: 'MATCH m1',
    ),
    (
      type: NotificationType.newMessage,
      entity: _notification(
        id: 'n2',
        type: NotificationType.newMessage,
        matchId: 'm2',
      ),
      expected: 'CHAT m2',
    ),
    (
      type: NotificationType.itemRecovered,
      entity: _notification(
        id: 'n3',
        type: NotificationType.itemRecovered,
        reportId: 'r1',
      ),
      expected: 'REPORT r1',
    ),
  ]) {
    testWidgets('tapping a ${testCase.type.raw} notification opens its route', (
      tester,
    ) async {
      final harness = _Harness(notifications: [testCase.entity]);
      addTearDown(harness.dispose);
      await harness.load();

      await pumpTestRouterApp(tester, buildRouter(harness.cubit));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(ValueKey('notification_${testCase.entity.id}')),
      );
      await tester.pumpAndSettle();

      expect(find.text(testCase.expected), findsOneWidget);
      expect(harness.repository.markedIds, [testCase.entity.id]);
      expect(harness.cubit.state.unreadCount, 0);
    });
  }

  testWidgets('shows the empty state', (tester) async {
    final harness = _Harness();
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notifications_empty')), findsOneWidget);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('shows the error state and retries successfully', (tester) async {
    final harness = _Harness(
      loadError: const NotificationsFailure(NotificationsFailureType.network),
    );
    addTearDown(harness.dispose);
    await harness.load();

    await pumpScreen(tester, harness.cubit);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notifications_error')), findsOneWidget);
    expect(find.text("Couldn't load notifications"), findsOneWidget);

    harness.repository.loadError = null;
    harness.repository.notifications = [
      _notification(id: 'n1', actorName: 'Mona K.'),
    ];
    await tester.tap(find.byKey(const ValueKey('notifications_retry')));
    await tester.pumpAndSettle();

    expect(find.text('New message from Mona K.'), findsOneWidget);
  });
}
