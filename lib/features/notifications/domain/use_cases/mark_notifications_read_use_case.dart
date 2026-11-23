import 'package:found_it/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationsReadUseCase {
  const MarkNotificationsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  /// [id] null = mark all as read (`mark_notifications_read` with no params).
  Future<void> call({String? id}) => _repository.markNotificationsRead(id: id);
}
