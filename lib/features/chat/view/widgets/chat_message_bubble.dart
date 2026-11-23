import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/features/chat/domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.showDateHeader = false,
    this.dateHeaderLabel,
    this.onRetry,
  });

  final ChatMessageEntity message;
  final bool showDateHeader;
  final String? dateHeaderLabel;
  final ValueChanged<String>? onRetry;

  String _formatTime(DateTime date) {
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '$hour:$min $period';
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(12.r),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 20.sp),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMine = message.isMine;
    final timeStr = _formatTime(message.createdAt);
    final hasImage = message.hasImage;
    final imageUrl = message.imageUrl;

    return Column(
      children: [
        if (showDateHeader && dateHeaderLabel != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                dateHeaderLabel!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 0.76.sw,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: isMine ? Radius.circular(18.r) : Radius.circular(4.r),
                    bottomRight: isMine ? Radius.circular(4.r) : Radius.circular(18.r),
                  ),
                  gradient: isMine
                      ? (message.hasFailed
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF991B1B), Color(0xFF7F1D1D)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2F5BEA), Color(0xFF1D4ED8)],
                            ))
                      : null,
                  color: isMine
                      ? null
                      : (isDark
                          ? const Color(0xFF1E2638)
                          : const Color(0xFFF1F5F9)),
                  border: isMine
                      ? null
                      : Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                          width: 1.0,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.25 : 0.05,
                      ),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.r),
                    topRight: Radius.circular(18.r),
                    bottomLeft: isMine ? Radius.circular(18.r) : Radius.circular(4.r),
                    bottomRight: isMine ? Radius.circular(4.r) : Radius.circular(18.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Attachment (if present)
                      if (hasImage) ...[
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showImagePreview(context, imageUrl),
                            child: Hero(
                              tag: 'chat_img_${message.id}',
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: isDark
                                          ? const Color(0xFF161F30)
                                          : const Color(0xFFE2E8F0),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, _, _) => Container(
                                    color: isDark
                                        ? const Color(0xFF161F30)
                                        : const Color(0xFFE2E8F0),
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        size: 32.sp,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          // Photo is uploading or signed URL loading
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Container(
                              color: isDark
                                  ? const Color(0xFF161F30)
                                  : const Color(0xFFE2E8F0),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ),
                          ),
                      ],

                      // Message Text & Metadata
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          12.w,
                          hasImage ? 6.h : 9.h,
                          12.w,
                          7.h,
                        ),
                        child: Column(
                          crossAxisAlignment: isMine
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message.body != null &&
                                message.body!.isNotEmpty) ...[
                              Text(
                                message.body!,
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                  color: isMine
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                            ],
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isMine
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : theme.colorScheme.onSurfaceVariant
                                            .withValues(alpha: 0.65),
                                  ),
                                ),
                                if (isMine) ...[
                                  SizedBox(width: 4.w),
                                  if (message.hasFailed)
                                    GestureDetector(
                                      onTap: () => onRetry?.call(message.id),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            size: 13.sp,
                                            color: const Color(0xFFFCA5A5),
                                          ),
                                          SizedBox(width: 2.w),
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 13.sp,
                                            color: const Color(0xFFFCA5A5),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (message.isSending)
                                    SizedBox(
                                      width: 10.r,
                                      height: 10.r,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Colors.white70,
                                        ),
                                      ),
                                    )
                                  else
                                    Icon(
                                      message.isRead
                                          ? Icons.done_all_rounded
                                          : Icons.done_rounded,
                                      size: 14.sp,
                                      color: message.isRead
                                          ? const Color(0xFF67E8F9)
                                          : Colors.white70,
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
            ),
          ),
        ),
      ],
    );
  }
}
