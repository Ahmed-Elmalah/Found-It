import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/models/notification_type.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/view/widgets/notification_texts.dart';

/// One notification row (P30 / P64).
///
/// Unread rows use the primary color as a tint + border + dot, read rows fall
/// back to the plain surface so the difference survives light and dark themes.
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification, this.onTap});

  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final text = notificationText(l10n, notification);
    final unread = !notification.isRead;
    final radius = BorderRadius.circular(16.r);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: Material(
        color: unread
            ? colors.primary.withValues(alpha: isDark ? 0.12 : 0.05)
            : colors.surface,
        borderRadius: radius,
        child: InkWell(
          key: ValueKey('notification_${notification.id}'),
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: unread
                    ? colors.primary.withValues(alpha: isDark ? 0.45 : 0.30)
                    : colors.outline,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeIcon(type: notification.type, unread: unread),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              text.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: unread
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                height: 1.3,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            SizedBox(width: 8.w),
                            Semantics(
                              label: l10n.notificationsUnread,
                              child: Container(
                                key: ValueKey(
                                  'notification_unread_dot_${notification.id}',
                                ),
                                margin: EdgeInsets.only(top: 5.h),
                                width: 8.r,
                                height: 8.r,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        text.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.45,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _timeLabel(context, notification.createdAt),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurfaceVariant.withValues(
                            alpha: unread ? 0.9 : 0.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Time for today, date + time for older rows (MaterialLocalizations keeps
  /// it localized and RTL-safe without extra intl setup).
  static String _timeLabel(BuildContext context, DateTime createdAt) {
    final material = MaterialLocalizations.of(context);
    final local = createdAt.toLocal();
    final now = DateTime.now();
    final time = material.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    final isToday =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return isToday ? time : '${material.formatShortDate(local)} · $time';
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type, required this.unread});

  final NotificationType? type;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = unread ? colors.primary : colors.onSurfaceVariant;

    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: unread ? 0.16 : 0.10),
      ),
      child: Icon(_iconFor(type), size: 20.r, color: color),
    );
  }

  static IconData _iconFor(NotificationType? type) {
    switch (type) {
      case NotificationType.potentialMatch:
        return Icons.compare_arrows_rounded;
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.ownershipVerified:
        return Icons.verified_rounded;
      case NotificationType.matchRejected:
        return Icons.link_off_rounded;
      case NotificationType.itemRecovered:
        return Icons.check_circle_outline_rounded;
      case NotificationType.claimPassed:
        return Icons.quiz_outlined;
      case null:
        return Icons.notifications_none_rounded;
    }
  }
}
