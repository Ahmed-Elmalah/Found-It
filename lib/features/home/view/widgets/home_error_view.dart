import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

class HomeErrorView extends StatefulWidget {
  const HomeErrorView({
    super.key,
    required this.onRetry,
  });

  final Future<void> Function() onRetry;

  @override
  State<HomeErrorView> createState() => _HomeErrorViewState();
}

class _HomeErrorViewState extends State<HomeErrorView> {
  bool _isLoading = false;

  Future<void> _handleRetry() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: widget.onRetry,
      color: primary,
      backgroundColor: theme.colorScheme.surface,
      displacement: 24.h,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        children: [
          SizedBox(height: 55.h),

          // Error sphere
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF4444).withValues(
                      alpha: isDark ? 0.08 : 0.04,
                    ),
                  ),
                ),
                // Inner ring
                Container(
                  width: 90.r,
                  height: 90.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF4444).withValues(
                      alpha: isDark ? 0.14 : 0.08,
                    ),
                  ),
                ),
                // Core
                Container(
                  width: 66.r,
                  height: 66.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEF4444),
                        Color(0xFFDC2626),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                        blurRadius: 18.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 350.ms),
          ),
          SizedBox(height: 28.h),

          // Title
          Text(
            l10n.homeErrorTitle,
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
            l10n.homeErrorSubtitle,
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

          // Retry Button
          Center(
            child: InkWell(
              onTap: _isLoading ? null : _handleRetry,
              borderRadius: BorderRadius.circular(24.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border.all(
                    color: primary.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
                        ),
                      )
                    else
                      Icon(
                        Icons.refresh_rounded,
                        color: primary,
                        size: 20.r,
                      ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        l10n.homeRetryButton,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primary,
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 350.ms)
              .scale(curve: Curves.easeOutBack),

          SizedBox(height: 120.h),
        ],
      ),
    );
  }
}
