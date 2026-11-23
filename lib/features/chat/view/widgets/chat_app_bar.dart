import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    this.chatInfo,
    this.isVerified = false,
    this.onRejectMatch,
  });

  final ChatItemEntity? chatInfo;
  final bool isVerified;
  final VoidCallback? onRejectMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final baseBarHeight = 58.h;
    final totalHeight = topPadding + baseBarHeight;

    final name = chatInfo?.otherUserName.isNotEmpty == true
        ? chatInfo!.otherUserName
        : 'Chat';
    final report = chatInfo?.displayReport;
    final isLost = report?.isLost ?? !(chatInfo?.iAmFinder ?? false);
    final reportTitle = report?.title ?? '';

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: totalHeight,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F1523).withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.8,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Back Button (Circular Glass Badge)
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  iconSize: 18.sp,
                  isDark: isDark,
                  iconColor: theme.colorScheme.onSurface,
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.messages);
                    }
                  },
                ),
                SizedBox(width: 10.w),

                // Avatar Preview
                _buildAvatar(chatInfo, isDark),
                SizedBox(width: 10.w),

                // User Info + Report Subtitle
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (isVerified) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.verified_rounded,
                              size: 15.sp,
                              color: const Color(0xFF10B981),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          if (reportTitle.isNotEmpty)
                            Flexible(
                              child: Text(
                                '${isLost ? l10n.lost : l10n.found} · $reportTitle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            )
                          else
                            Text(
                              l10n.chatOnline,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Options Button (Circular Glass Badge) - hidden if closed
                if (chatInfo?.isClosed != true)
                  _CircleIconButton(
                    icon: Icons.more_vert_rounded,
                    iconSize: 20.sp,
                    isDark: isDark,
                    iconColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    onTap: () => _showOptionsMenu(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF131B2A).withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    tileColor: isDark
                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                        : const Color(0xFFFEE2E2),
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFEF4444),
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      l10n.chatRejectMatch,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _showGlassRejectConfirmDialog(context);
                    },
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGlassRejectConfirmDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reject Match',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18 * animation.value,
            sigmaY: 18 * animation.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: animation,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF162033).withValues(alpha: 0.94)
                              : Colors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.14)
                                : Colors.black.withValues(alpha: 0.08),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.45 : 0.15,
                              ),
                              blurRadius: 30.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60.r,
                              height: 60.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEF4444)
                                    .withValues(alpha: 0.15),
                                border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: const Color(0xFFEF4444),
                                  size: 32.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.chatRejectConfirmTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              l10n.chatRejectConfirmBody,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                height: 1.45,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(ctx).pop(),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.08)
                                            : Colors.black
                                                .withValues(alpha: 0.05),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.10)
                                              : Colors.black
                                                  .withValues(alpha: 0.06),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          l10n.cancel,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      Navigator.of(ctx).pop();
                                      onRejectMatch?.call();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFEF4444),
                                            Color(0xFFDC2626),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFEF4444)
                                                .withValues(alpha: 0.35),
                                            blurRadius: 10.r,
                                            offset: Offset(0, 4.h),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          l10n.chatRejectConfirmAction,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(ChatItemEntity? chat, bool isDark) {
    final avatarUrl = chat?.otherUserAvatar;
    final initials = chat?.otherUserName.isNotEmpty == true
        ? chat!.otherUserName[0].toUpperCase()
        : '?';

    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF243044) : const Color(0xFFE2E8F0),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 40.r,
                height: 40.r,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E2638),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E2638),
                  ),
                ),
              ),
      ),
    );
  }
}

class _CircleIconButton extends StatefulWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconSize,
    required this.isDark,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final bool isDark;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? Colors.white.withValues(alpha: _isPressed ? 0.15 : 0.08)
                : Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.04),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
