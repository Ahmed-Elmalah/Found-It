import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class ChatSafetyBanner extends StatefulWidget {
  const ChatSafetyBanner({super.key});

  @override
  State<ChatSafetyBanner> createState() => _ChatSafetyBannerState();
}

class _ChatSafetyBannerState extends State<ChatSafetyBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2415)
            : const Color(0xFFFEF9C3).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFFEAB308).withValues(alpha: 0.3)
              : const Color(0xFFEAB308).withValues(alpha: 0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18.sp,
            color: isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.chatSafetyBanner,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color:
                    isDark ? const Color(0xFFFEF08A) : const Color(0xFF854D0E),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: isDark
                    ? const Color(0xFFFDE047).withValues(alpha: 0.7)
                    : const Color(0xFF854D0E).withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
