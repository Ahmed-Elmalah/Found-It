import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class ChatListEmptyView extends StatelessWidget {
  const ChatListEmptyView({
    super.key,
    this.isSearchEmpty = false,
    this.isError = false,
    this.onRetry,
  });

  final bool isSearchEmpty;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    final title = isError
        ? l10n.messagesFailedTitle
        : (isSearchEmpty
            ? l10n.emptySearchTitle
            : l10n.messagesEmptyTitle);

    final subtitle = isError
        ? l10n.messagesFailedSubtitle
        : (isSearchEmpty
            ? l10n.emptySearchMessage
            : l10n.messagesEmptySubtitle);

    final icon = isError
        ? Icons.cloud_off_rounded
        : (isSearchEmpty
            ? Icons.search_off_rounded
            : Icons.chat_bubble_outline_rounded);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Concentric circular icon halo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110.r,
                height: 110.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isError
                      ? (isDark
                          ? const Color(0xFF3F1717).withValues(alpha: 0.4)
                          : const Color(0xFFFEE2E2).withValues(alpha: 0.6))
                      : primary.withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
              Container(
                width: 82.r,
                height: 82.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isError
                      ? (isDark
                          ? const Color(0xFF3F1717)
                          : const Color(0xFFFEE2E2))
                      : primary.withValues(alpha: isDark ? 0.16 : 0.10),
                ),
                child: Icon(
                  icon,
                  size: 38.sp,
                  color: isError
                      ? const Color(0xFFDC2626)
                      : primary,
                ),
              ),
            ],
          )
              .animate()
              .scale(
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
          SizedBox(height: 24.h),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
            ),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

          // Retry Button if error
          if (isError && onRetry != null) ...[
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry?.call();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.messagesRetry),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 11.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
            ).animate().fadeIn(delay: 350.ms).scale(),
          ],
        ],
      ),
    );
  }
}
