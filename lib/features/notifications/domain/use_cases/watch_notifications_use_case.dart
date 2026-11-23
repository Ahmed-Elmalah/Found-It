import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';

class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Stream<List<NotificationEntity>> call() => _repository.watchNotifications();
}
