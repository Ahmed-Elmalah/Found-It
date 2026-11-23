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
  });

  final ChatItemEntity? chatInfo;
  final bool isVerified;

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

                // Options Button (Circular Glass Badge)
                _CircleIconButton(
                  icon: Icons.more_vert_rounded,
                  iconSize: 20.sp,
                  isDark: isDark,
                  iconColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  onTap: () {
                    // Quick feedback
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
