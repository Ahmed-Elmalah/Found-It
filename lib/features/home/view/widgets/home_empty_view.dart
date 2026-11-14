import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:found_it/core/localization/app_localizations.dart';
import 'package:found_it/core/router/app_routes.dart';

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({
    super.key,
    required this.cityName,
    required this.onRefresh,
  });

  final String cityName;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: primary,
      backgroundColor: theme.colorScheme.surface,
      displacement: 24.h,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        children: [
          SizedBox(height: 50.h),

          // Floating concentric glowing illustration
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
                    color: primary.withValues(alpha: isDark ? 0.08 : 0.04),
                  ),
                ),
                // Inner ring
                Container(
                  width: 96.r,
                  height: 96.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: isDark ? 0.14 : 0.08),
                  ),
                ),
                // Core icon sphere
                Container(
                  width: 68.r,
                  height: 68.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
                        blurRadius: 18.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_off_rounded,
                      color: Colors.white,
                      size: 34,
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
            l10n.homeEmptyTitle(cityName),
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
            l10n.homeEmptySubtitle,
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
          Center(
            child: _EmptyActionButton(
              label: l10n.homeEmptyAction,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push(AppRoutes.createReport);
              },
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

class _EmptyActionButton extends StatefulWidget {
  const _EmptyActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
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
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 6.w),
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
