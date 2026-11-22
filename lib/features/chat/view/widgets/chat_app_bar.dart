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
    final baseBarHeight = 56.h;
    final totalHeight = topPadding + baseBarHeight;

    final name = chatInfo?.otherUserName.isNotEmpty == true
        ? chatInfo!.otherUserName
        : 'Chat';
    final report = chatInfo?.displayReport;
    final isLost = report?.isLost ?? !(chatInfo?.iAmFinder ?? false);
    final reportTitle = report?.title ?? '';

    return Container(
      height: totalHeight,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? Colors.black : Colors.white).withValues(alpha: 0.95),
            (isDark ? Colors.black : Colors.white).withValues(alpha: 0.80),
            (isDark ? theme.scaffoldBackgroundColor : Colors.white)
                .withValues(alpha: 0.50),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 0.80, 1.0],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button (iOS Chevron)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20.sp,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.messages);
                }
              },
            ),

            // Avatar Preview
            _buildAvatar(chatInfo, isDark),
            SizedBox(width: 10.w),

            // User Info + Report Title
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

            // More Options / Actions Button
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 22.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
              },
            ),
          ],
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
              ? Colors.white.withValues(alpha: 0.12)
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
