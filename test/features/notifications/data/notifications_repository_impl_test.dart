import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/notifications/data/models/notification_model.dart';
import 'package:found_it/features/notifications/data/notifications_remote_data_source.dart';
import 'package:found_it/features/notifications/data/notifications_repository_impl.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';

class _FakeNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  List<NotificationModel> rows = const [];
  Object? error;
  final List<String?> markedIds = [];
  Exception? watchError;

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    if (error != null) throw error!;
    return rows;
  }

  @override
  Future<void> markNotificationsRead({String? id}) async {
    if (error != null) throw error!;
    markedIds.add(id);
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    final watchError = this.watchError;
    if (watchError != null) return Stream.error(watchError);
    return Stream.value(rows);
  }
}

void main() {
  late _FakeNotificationsRemoteDataSource remote;
  late NotificationsRepositoryImpl repository;

  setUp(() {
    remote = _FakeNotificationsRemoteDataSource();
    repository = NotificationsRepositoryImpl(remoteDataSource: remote);
  });

  group('NotificationsRepositoryImpl failure mapping', () {
    test('Postgrest 42501 becomes unauthorized', () async {
      remote.error = const PostgrestException(
        message: 'permission denied for table notifications',
        code: '42501',
      );

      await expectLater(
        repository.getMyNotifications(),
        throwsA(
          isA<NotificationsFailure>().having(
            (failure) => failure.type,
            'type',
            NotificationsFailureType.unauthorized,
          ),
        ),
      );
    });

    test('Postgrest PGRST301 becomes unauthorized', () async {
      remote.error = const PostgrestException(
        message: 'JWT expired',
        code: 'PGRST301',
      );

      await expectLater(
        repository.markNotificationsRead(),
        throwsA(
          isA<NotificationsFailure>().having(
            (failure) => failure.type,
            'type',
            NotificationsFailureType.unauthorized,
          ),
        ),
      );
    });

    test('other Postgrest errors become server failures', () async {
      remote.error = const PostgrestException(
        message: 'column does not exist',
        code: '42703',
      );

      await expectLater(
        repository.getMyNotifications(),
        throwsA(
          isA<NotificationsFailure>().having(
            (failure) => failure.type,
            'type',
            NotificationsFailureType.server,
          ),
        ),
      );
    });

    test('timeouts become network failures', () async {
      remote.error = TimeoutException('slow');

      await expectLater(
        repository.getMyNotifications(),
        throwsA(
          isA<NotificationsFailure>().having(
            (failure) => failure.type,
            'type',
            NotificationsFailureType.network,
          ),
        ),
      );
    });

    test('unexpected errors become unknown (message is not leaked)', () async {
      remote.error = StateError('database exploded');

      await expectLater(
        repository.getMyNotifications(),
        throwsA(
          isA<NotificationsFailure>()
              .having(
                (failure) => failure.type,
                'type',
                NotificationsFailureType.unknown,
              )
              .having((failure) => failure.code, 'code', isNull),
        ),
      );
    });

    test('stream errors are mapped too', () async {
      remote.watchError = TimeoutException('slow');

      await expectLater(
        repository.watchNotifications(),
        emitsError(
          isA<NotificationsFailure>().having(
            (failure) => failure.type,
            'type',
            NotificationsFailureType.network,
          ),
        ),
      );
    });
  });

  group('NotificationsRepositoryImpl calls', () {
    test('mark one passes the id, mark all passes null', () async {
      await repository.markNotificationsRead(id: 'n1');
      await repository.markNotificationsRead();

      expect(remote.markedIds, ['n1', null]);
    });

    test('returns the rows from the data source', () async {
      remote.rows = [
        NotificationModel(id: 'n1', createdAt: DateTime(2026, 1, 1)),
      ];

      final rows = await repository.getMyNotifications();

      expect(rows.single.id, 'n1');
    });
  });
}
