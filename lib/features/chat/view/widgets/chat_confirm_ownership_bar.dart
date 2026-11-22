import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';

class ChatConfirmOwnershipBar extends StatelessWidget {
  const ChatConfirmOwnershipBar({
    super.key,
    required this.matchId,
    required this.isVerified,
    required this.isConfirming,
    required this.onConfirm,
  });

  final String matchId;
  final bool isVerified;
  final bool isConfirming;
  final VoidCallback onConfirm;

  void _showConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: const Color(0xFF10B981),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                l10n.chatConfirmDialogTitle,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.chatConfirmDialogBody,
          style: TextStyle(
            fontSize: 13.5.sp,
            height: 1.4,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              HapticFeedback.heavyImpact();
              onConfirm();
            },
            child: Text(
              l10n.confirm,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (isVerified) {
      // Verified Banner with Handover Action Link
      return Container(
        margin: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
              : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatOwnershipVerified,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFF047857),
                    ),
                  ),
                  Text(
                    l10n.chatHandoverInstructions,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isDark
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: isDark
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFF047857),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(AppRoutes.handoverPath(matchId));
              },
            ),
          ],
        ),
      );
    }

    // Unverified: Prominent Action Button to Confirm Ownership
    return Container(
      margin: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2338) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.chatConfirmOwnership,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  l10n.chatConfirmOwnershipSub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              minimumSize: Size(60.w, 36.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: isConfirming ? null : () => _showConfirmationDialog(context),
            child: isConfirming
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n.confirm,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
