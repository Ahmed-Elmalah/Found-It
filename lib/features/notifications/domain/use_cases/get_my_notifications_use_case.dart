import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';

class GetMyNotificationsUseCase {
  const GetMyNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<List<NotificationEntity>> call() => _repository.getMyNotifications();
}
