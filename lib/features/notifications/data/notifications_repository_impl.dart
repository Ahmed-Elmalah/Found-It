import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/notifications/data/notifications_remote_data_source.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/entities/notifications_failure.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({required this.remoteDataSource});

  final NotificationsRemoteDataSource remoteDataSource;

  @override
  Future<List<NotificationEntity>> getMyNotifications() async {
    try {
      return await remoteDataSource.getMyNotifications();
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Future<void> markNotificationsRead({String? id}) async {
    try {
      await remoteDataSource.markNotificationsRead(id: id);
    } catch (error) {
      throw _mapFailure(error);
    }
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return remoteDataSource.watchNotifications().handleError(
      (Object error) => throw _mapFailure(error),
    );
  }

  NotificationsFailure _mapFailure(Object error) {
    if (error is NotificationsFailure) return error;

    if (error is PostgrestException) {
      return switch (error.code) {
        '42501' => NotificationsFailure(
          NotificationsFailureType.unauthorized,
          error.code,
        ),
        'PGRST301' || 'PGRST302' => NotificationsFailure(
          NotificationsFailureType.unauthorized,
          error.code,
        ),
        _ => NotificationsFailure(NotificationsFailureType.server, error.code),
      };
    }

    if (error is AuthRetryableFetchException || error is TimeoutException) {
      return const NotificationsFailure(NotificationsFailureType.network);
    }

    final typeName = error.runtimeType.toString();
    if (typeName.contains('Socket') || typeName.contains('ClientException')) {
      return const NotificationsFailure(NotificationsFailureType.network);
    }

    return const NotificationsFailure(NotificationsFailureType.unknown);
  }
}
