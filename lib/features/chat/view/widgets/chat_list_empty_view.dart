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
    this.onClearFilters,
    this.onExplore,
  });

  final bool isSearchEmpty;
  final bool isError;
  final VoidCallback? onRetry;
  final VoidCallback? onClearFilters;
  final VoidCallback? onExplore;

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

    final String actionLabel = isError
        ? l10n.messagesRetry
        : (isSearchEmpty
            ? l10n.messagesClearFilters
            : l10n.messagesExploreAction);

    final IconData actionIcon = isError
        ? Icons.refresh_rounded
        : (isSearchEmpty
            ? Icons.filter_alt_off_rounded
            : Icons.explore_rounded);

    final VoidCallback? actionCallback = isError
        ? onRetry
        : (isSearchEmpty
            ? onClearFilters
            : onExplore);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30.h),

          // Floating concentric glowing illustration (Exact Home DNA)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle halo
                Container(
                  width: 130.r,
                  height: 130.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isError
                        ? (isDark
                            ? const Color(0xFF3F1717).withValues(alpha: 0.25)
                            : const Color(0xFFFEE2E2).withValues(alpha: 0.5))
                        : primary.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                ),

                // Inner ring
                Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isError
                        ? (isDark
                            ? const Color(0xFF3F1717).withValues(alpha: 0.45)
                            : const Color(0xFFFEE2E2).withValues(alpha: 0.8))
                        : primary.withValues(alpha: isDark ? 0.14 : 0.08),
                  ),
                ),

                // Core icon sphere
                Container(
                  width: 68.r,
                  height: 68.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isError
                          ? [
                              const Color(0xFFEF4444),
                              const Color(0xFFDC2626),
                            ]
                          : [
                              primary,
                              primary.withValues(alpha: 0.8),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isError ? const Color(0xFFDC2626) : primary)
                            .withValues(alpha: 0.35),
                        blurRadius: 18.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 34.r,
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .scale(
                  duration: 450.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 400.ms),
          ),
          SizedBox(height: 28.h),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 350.ms)
              .slideY(begin: 0.15, end: 0),
          SizedBox(height: 10.h),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 350.ms)
              .slideY(begin: 0.15, end: 0),
          SizedBox(height: 28.h),

          // Action CTA button
          if (actionCallback != null)
            Center(
              child: _EmptyActionButton(
                label: actionLabel,
                icon: actionIcon,
                onTap: () {
                  HapticFeedback.lightImpact();
                  actionCallback();
                },
              ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 350.ms)
                .scale(curve: Curves.easeOutBack),

          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}

class _EmptyActionButton extends StatefulWidget {
  const _EmptyActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_EmptyActionButton> createState() => _EmptyActionButtonState();
}

class _EmptyActionButtonState extends State<_EmptyActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              colors: [
                primary,
                const Color(0xFF1D4ED8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.35),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
