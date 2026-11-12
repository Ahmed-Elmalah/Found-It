import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// An ultra-clear "iOS 27" Liquid Glass Navigation Bar powered by [liquid_glass_renderer].
///
/// Features:
/// - **Native iOS 27 Glass:** Uses [LiquidGlassLayer] with [LiquidGlassSettings.ios27RegularLight]
///   and [LiquidGlassSettings.ios27RegularDark] for optical refraction and specular edge glint.
/// - **Metaball Melting Blend Group:** [LiquidGlassBlendGroup] groups the outer capsule dock,
///   the center Plus button, and the sliding Glass Loupe so their SDF fields organically melt together.
/// - **5 Slots:** Home, Explore, Center Report Button (with Plus `+` icon), Messages (with badge `2`), Profile.
/// - **Spring Physics:** Elastic bounce transitions when switching tabs.
class LiquidGlassBottomNavBar extends StatefulWidget {
  const LiquidGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onReportTap,
  });

  /// Active tab index among the 4 destinations:
  /// 0: Home, 1: Explore, 2: Messages, 3: Profile.
  final int currentIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTap;

  /// Callback when the center Plus button is tapped.
  final VoidCallback onReportTap;

  @override
  State<LiquidGlassBottomNavBar> createState() => _LiquidGlassBottomNavBarState();
}

class _LiquidGlassBottomNavBarState extends State<LiquidGlassBottomNavBar>
    with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _plusTapController;

  late Animation<double> _alignmentAnimation;
  late Animation<double> _stretchAnimation;

  double _previousAlignmentX = -1.0;
  double _currentAlignmentX = -1.0;

  @override
  void initState() {
    super.initState();
    _currentAlignmentX = _getAlignmentForIndex(widget.currentIndex);
    _previousAlignmentX = _currentAlignmentX;

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _plusTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _buildAnimations(_currentAlignmentX, _currentAlignmentX);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      final newAlignmentX = _getAlignmentForIndex(widget.currentIndex);
      _previousAlignmentX = _currentAlignmentX;
      _currentAlignmentX = newAlignmentX;

      _buildAnimations(_previousAlignmentX, _currentAlignmentX);
      _motionController.forward(from: 0.0);
    }
  }

  void _buildAnimations(double fromX, double toX) {
    _alignmentAnimation = Tween<double>(begin: fromX, end: toX).animate(
      CurvedAnimation(
        parent: _motionController,
        curve: Curves.easeOutBack,
      ),
    );

    _stretchAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.28)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.28, end: 0.92)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_motionController);
  }

  double _getAlignmentForIndex(int index) {
    // 5 slots: Tab 0 (-1.0), Tab 1 (-0.5), Center Plus (0.0), Tab 2 (0.5), Tab 3 (1.0)
    return switch (index) {
      0 => -1.0,
      1 => -0.5,
      2 => 0.5,
      3 => 1.0,
      _ => -1.0,
    };
  }

  @override
  void dispose() {
    _motionController.dispose();
    _plusTapController.dispose();
    super.dispose();
  }

  void _handlePlusTap() {
    HapticFeedback.mediumImpact();
    _plusTapController.forward(from: 0.0);
    widget.onReportTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final glassSettings = isDark
        ? LiquidGlassSettings.ios27RegularDark()
        : LiquidGlassSettings.ios27RegularLight();

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
          child: LiquidGlassLayer(
            settings: glassSettings,
            child: LiquidGlassBlendGroup(
              blend: 26.0, // Melting threshold distance
              child: Container(
                height: 68.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.06),
                      blurRadius: 28.r,
                      offset: Offset(0, 10.h),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: LiquidGlass.grouped(
                  shape: LiquidRoundedRectangle(
                    borderRadius: 34.r,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Active Glass Loupe lens that slides and melts with other shapes
                      AnimatedBuilder(
                        animation: _motionController,
                        builder: (context, _) {
                          final currentX = _alignmentAnimation.value;
                          final stretch = _stretchAnimation.value;

                          return Align(
                            alignment: AlignmentDirectional(currentX, 0),
                            child: FractionallySizedBox(
                              widthFactor: 0.20 * stretch,
                              heightFactor: 0.84 / math.sqrt(stretch),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                child: LiquidGlass.grouped(
                                  shape: LiquidOval(),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // 5 Interactive slots
                      Row(
                        children: [
                          // Tab 0: Home
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.home_rounded,
                              label: l10n.navHome,
                              isSelected: widget.currentIndex == 0,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onTap(0);
                              },
                            ),
                          ),

                          // Tab 1: Explore
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.explore_rounded,
                              label: l10n.navExplore,
                              isSelected: widget.currentIndex == 1,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onTap(1);
                              },
                            ),
                          ),

                          // Center Slot: Report Button with Plus '+' Icon
                          Expanded(
                            child: _CenterReportPlusButton(
                              label: l10n.navReport,
                              tapAnimation: _plusTapController,
                              onTap: _handlePlusTap,
                            ),
                          ),

                          // Tab 2: Messages (with badge '2')
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.chat_bubble_rounded,
                              label: l10n.navMessages,
                              isSelected: widget.currentIndex == 2,
                              badgeCount: 2,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onTap(2);
                              },
                            ),
                          ),

                          // Tab 3: Profile
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.person_rounded,
                              label: l10n.navProfile,
                              isSelected: widget.currentIndex == 3,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onTap(3);
                              },
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
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final color = isSelected ? primary : onSurfaceVariant.withValues(alpha: 0.65);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSlide(
                  offset: isSelected ? const Offset(0, -0.08) : Offset.zero,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: AnimatedScale(
                    scale: isSelected ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      icon,
                      color: color,
                      size: 24.r,
                    ),
                  ),
                ),
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    top: -2.h,
                    right: -6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.2,
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.r,
                        minHeight: 16.r,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 3.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: color,
                fontSize: 10.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterReportPlusButton extends StatelessWidget {
  const _CenterReportPlusButton({
    required this.label,
    required this.tapAnimation,
    required this.onTap,
  });

  final String label;
  final Animation<double> tapAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: tapAnimation,
              builder: (context, _) {
                final tapScale = 1.0 - (tapAnimation.value * 0.10);

                return Transform.scale(
                  scale: tapScale,
                  child: Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3B66FF),
                          Color(0xFF1D4ED8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(
                            alpha: isDark ? 0.45 : 0.35,
                          ),
                          blurRadius: 12.r,
                          offset: Offset(0, 3.h),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.50),
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded, // Plus '+' icon as requested
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
