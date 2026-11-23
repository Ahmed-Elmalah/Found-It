import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:found_it/features/notifications/data/models/notification_model.dart';

/// All Supabase access for notifications lives here. Cubits and screens never
/// import `supabase_flutter`.
abstract interface class NotificationsRemoteDataSource {
  /// Newest first, 50 rows (Section 8).
  Future<List<NotificationModel>> getMyNotifications();

  /// [id] null = "Mark all read".
  Future<void> markNotificationsRead({String? id});

  /// Live updates for the same 50 rows (Supabase Realtime).
  Stream<List<NotificationModel>> watchNotifications();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  const NotificationsRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    final rows = await _supabase
        .from('notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map(NotificationModel.fromJson).toList(growable: false);
  }

  @override
  Future<void> markNotificationsRead({String? id}) async {
    if (id == null) {
      await _supabase.rpc('mark_notifications_read');
      return;
    }
    await _supabase.rpc(
      'mark_notifications_read',
      params: {
        'p_ids': [id],
      },
    );
  }

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map(
          (rows) =>
              rows.map(NotificationModel.fromJson).toList(growable: false),
        );
  }
}
