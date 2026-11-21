import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/features/chat/domain/entities/chat_item_entity.dart';

class ChatListCard extends StatefulWidget {
  const ChatListCard({
    super.key,
    required this.chat,
    this.onTap,
  });

  final ChatItemEntity chat;
  final VoidCallback? onTap;

  @override
  State<ChatListCard> createState() => _ChatListCardState();
}

class _ChatListCardState extends State<ChatListCard> {
  bool _isPressed = false;

  String _formatTimestamp(DateTime? date, BuildContext context) {
    if (date == null) return '';
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return l10n.messagesNow;
    } else if (diff.inHours < 1) {
      return l10n.homeMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24 && date.day == now.day) {
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final min = date.minute.toString().padLeft(2, '0');
      return '$hour:$min $period';
    } else if (diff.inDays < 2) {
      return l10n.messagesYesterday;
    } else if (diff.inDays < 7) {
      return l10n.homeDaysAgo(diff.inDays);
    } else {
      return '${date.day}/${date.month}';
    }
  }

  IconData _resolveCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.chat_bubble_outline_rounded;
    return switch (iconName.toLowerCase()) {
      'headphones' => Icons.headphones_rounded,
      'smartphone' || 'phone' || 'phones' => Icons.smartphone_rounded,
      'account_balance_wallet' || 'wallet' || 'wallets' =>
        Icons.account_balance_wallet_rounded,
      'key' || 'keys' => Icons.key_rounded,
      'badge' || 'document' || 'documents' => Icons.badge_outlined,
      'pets' || 'pet' => Icons.pets_rounded,
      'backpack' || 'bag' || 'bags' => Icons.backpack_outlined,
      'jewelry' => Icons.diamond_outlined,
      'accessories' => Icons.watch_outlined,
      _ => Icons.category_rounded,
    };
  }

  Widget _buildAvatarFallback(
    ChatItemEntity chat,
    bool isDark,
    Color accentColor,
  ) {
    final category = chat.displayReport?.categoryNameEn;
    if (category != null && category.isNotEmpty) {
      return Center(
        child: Icon(
          _resolveCategoryIcon(category),
          size: 26.sp,
          color: accentColor,
        ),
      );
    }

    final initials = chat.otherUserName.isNotEmpty
        ? chat.otherUserName.substring(0, 1).toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: accentColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildLeadingImage(ChatItemEntity chat, bool isDark) {
    final report = chat.displayReport;
    final imageUrl = report?.primaryImage;
    final accentColor =
        isDark ? const Color(0xFF8FA8FF) : const Color(0xFF2F5BEA);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58.r,
          height: 58.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: isDark ? const Color(0xFF243044) : const Color(0xFFF1F5F9),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 58.r,
                    height: 58.r,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildAvatarFallback(
                      chat,
                      isDark,
                      accentColor,
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : _buildAvatarFallback(chat, isDark, accentColor),
          ),
        ),

        // Verified green check badge
        if (chat.isVerified)
          Positioned(
            bottom: -2.r,
            right: -2.r,
            child: Container(
              padding: EdgeInsets.all(2.5.r),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF1E2638) : Colors.white,
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 4.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 10.r,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final chat = widget.chat;
    final report = chat.displayReport;
    final isLost = report?.isLost ?? !chat.iAmFinder;

    final tagBg = isLost
        ? (isDark ? const Color(0xFF3F1717) : const Color(0xFFFEE2E2))
        : (isDark ? const Color(0xFF0D3323) : const Color(0xFFD1FAE5));
    final tagText = isLost
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
        : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669));

    final hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutQuad,
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: isDark ? const Color(0xFF1E2638) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: hasUnread ? 0.16 : 0.08)
                  : (hasUnread
                      ? const Color(0xFF1B4B66).withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04)),
              width: hasUnread ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 4.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading Item Image (with verified badge if verified)
              _buildLeadingImage(chat, isDark),
              SizedBox(width: 14.w),

              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Tag (Lost/Found) + Match % + Timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 2.5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.r),
                                  color: tagBg,
                                ),
                                child: Text(
                                  isLost ? l10n.lost : l10n.found,
                                  style: TextStyle(
                                    color: tagText,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              if (chat.similarity > 0 &&
                                  chat.source == 'auto') ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E3A5F)
                                        : const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    '${chat.similarity}%',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formatTimestamp(
                            chat.lastMessageAt ?? chat.createdAt,
                            context,
                          ),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: hasUnread
                                ? const Color(0xFF1B4B66)
                                : theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.75),
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),

                    // User name & Report Context
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.otherUserName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight:
                                  hasUnread ? FontWeight.w800 : FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (report != null && report.title.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 110.w),
                            child: Text(
                              report.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Last Message + Unread Badge
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (chat.lastMessage?.hasImage == true) ...[
                                Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13.sp,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  l10n.messagesPhotoLabel,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.85),
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: Text(
                                    chat.lastMessage != null
                                        ? '${chat.lastMessage!.isMine ? l10n.messagesYouPrefix : ''}${chat.lastMessage!.body ?? ''}'
                                        : '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: hasUnread
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.75),
                                      fontWeight: hasUnread
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (hasUnread) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B4B66),
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B4B66)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 6.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
