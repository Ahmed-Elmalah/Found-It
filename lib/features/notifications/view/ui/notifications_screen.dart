import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/notifications/domain/entities/notification_entity.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_cubit.dart';
import 'package:found_it/features/notifications/view/cubit/notifications_state.dart';
import 'package:found_it/features/notifications/view/widgets/notification_card.dart';

/// Notifications screen (Figma P30 Light / P64 Dark).
///
/// Groups rows into Today / Earlier, marks them read on tap, and deep links
/// with the same mapping as the push payload (Section 8).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // The app already loads this on login; this covers a cold deep link into
    // the screen (or a screen opened before the session sync ran).
    final cubit = context.read<NotificationsCubit>();
    if (cubit.state.status == NotificationsStatus.initial) {
      unawaited(cubit.loadNotifications());
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleTap(NotificationEntity notification) async {
    final cubit = context.read<NotificationsCubit>();
    final l10n = AppLocalizations.of(context);
    final route = notification.route;

    // Optimistic: move immediately, mark read in the background.
    final marked = cubit.markAsRead(notification.id);
    if (route != null) {
      context.push(route);
    }

    final success = await marked;
    if (!success && mounted) {
      _showError(l10n.notificationsMarkReadError);
    }
  }

  Future<void> _handleMarkAllRead() async {
    final cubit = context.read<NotificationsCubit>();
    final l10n = AppLocalizations.of(context);
    final success = await cubit.markAllAsRead();
    if (!success && mounted) {
      _showError(l10n.notificationsMarkAllReadError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        final cubit = context.read<NotificationsCubit>();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _NotificationsHeader(
                  title: l10n.notificationsTitle,
                  markAllReadLabel: l10n.notificationsMarkAllRead,
                  onBack: _handleBack,
                  onMarkAllRead: state.hasUnread ? _handleMarkAllRead : null,
                ),
                Expanded(
                  child: switch (state.status) {
                    NotificationsStatus.initial ||
                    NotificationsStatus.loading =>
                      const _NotificationsLoadingView(),
                    NotificationsStatus.failure => _NotificationsStatusView(
                      key: const ValueKey('notifications_error'),
                      icon: Icons.cloud_off_rounded,
                      title: l10n.notificationsErrorTitle,
                      subtitle: l10n.notificationsErrorSubtitle,
                      actionLabel: l10n.retry,
                      actionIcon: Icons.refresh_rounded,
                      onAction: () => cubit.loadNotifications(),
                    ),
                    NotificationsStatus.success =>
                      state.notifications.isEmpty
                          ? _NotificationsStatusView(
                              key: const ValueKey('notifications_empty'),
                              icon: Icons.notifications_none_rounded,
                              title: l10n.notificationsEmptyTitle,
                              subtitle: l10n.notificationsEmptySubtitle,
                            )
                          : _NotificationsList(
                              state: state,
                              onNotificationTap: _handleTap,
                              onRefresh: () =>
                                  cubit.loadNotifications(showLoading: false),
                            ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({
    required this.title,
    required this.markAllReadLabel,
    required this.onBack,
    this.onMarkAllRead,
  });

  final String title;
  final String markAllReadLabel;
  final VoidCallback onBack;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onBack();
            },
            borderRadius: BorderRadius.circular(22.r),
            child: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 21.r,
                color: colors.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colors.onSurface,
              ),
            ),
          ),
          if (onMarkAllRead != null)
            TextButton(
              key: const ValueKey('notifications_mark_all_read'),
              onPressed: () {
                HapticFeedback.selectionClick();
                onMarkAllRead?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                markAllReadLabel,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.state,
    required this.onNotificationTap,
    required this.onRefresh,
  });

  final NotificationsState state;
  final ValueChanged<NotificationEntity> onNotificationTap;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // One "now" for both groups so an item never lands in neither section.
    final now = DateTime.now();
    final today = state.groupedToday(now);
    final earlier = state.groupedEarlier(now);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: ListView(
        key: const ValueKey('notifications_list'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(top: 4.h, bottom: 24.h),
        children: [
          if (today.isNotEmpty) _SectionHeader(label: l10n.notificationsToday),
          for (final item in today)
            NotificationCard(
              notification: item,
              onTap: () => onNotificationTap(item),
            ),
          if (earlier.isNotEmpty)
            _SectionHeader(label: l10n.notificationsEarlier),
          for (final item in earlier)
            NotificationCard(
              notification: item,
              onTap: () => onNotificationTap(item),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _NotificationsLoadingView extends StatelessWidget {
  const _NotificationsLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('notifications_loading'),
      child: SizedBox(
        width: 26.r,
        height: 26.r,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Shared empty / error state.
class _NotificationsStatusView extends StatelessWidget {
  const _NotificationsStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isError = icon == Icons.cloud_off_rounded;
    final accent = isError ? colors.error : colors.primary;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.r,
              height: 84.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: isDark ? 0.16 : 0.08),
              ),
              child: Icon(icon, size: 36.r, color: accent),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: colors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 22.h),
              FilledButton.tonalIcon(
                key: const ValueKey('notifications_retry'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onAction?.call();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: isDark ? 0.2 : 0.1),
                  foregroundColor: accent,
                  minimumSize: Size(0, 44.h),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                ),
                icon: Icon(actionIcon ?? Icons.refresh_rounded, size: 19.r),
                label: Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
