import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:found_it/core/localization/app_localizations.dart';

/// An ultra-clear "iOS 27" Liquid Glass Navigation Bar inspired by moza.flutter,
/// featuring optical glass refraction, a convex Glass Loupe active lens, and an organic
/// metaball melting bridge centered at the Report Plus button (نقطة الدوبان).
///
/// Key Architectural & Visual Mechanics:
/// 1. **Ultra-Clear Crystal Dock:** High-transparency frosted glass (~18% tint) with heavy blur (sigma: 24).
/// 2. **Specular Bevel Glint (اللمعة):** Physical light reflection sheen along the top-left beveled glass rim.
/// 3. **The Glass Loupe (عدسة الإزاز):** Circular convex optical lens that glides over the active tab,
///    featuring outer refraction rings and an inner specular glint.
/// 4. **Metaball Melting Furnace (نقطة الدوبان):** The center Plus button is the liquid source.
///    When switching tabs, a viscous organic liquid bridge (concave metaball neck) organically
///    stretches out of the Plus button, preserving volume with stretch-and-squash dynamics.
/// 5. **Spring Dynamics:** Elastic bounce physics on settling and tactile haptic reactions.
class LiquidGlassBottomNavBar extends StatefulWidget {
  const LiquidGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onReportTap,
  });

  /// Active tab index among the 4 destinations:
  /// 0: Home, 1: Explore, 2: Notifications, 3: Profile.
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
  late final AnimationController _pulseController;
  late final AnimationController _plusRotateController;

  late Animation<double> _alignmentAnimation;
  late Animation<double> _stretchAnimation;
  late Animation<double> _pulseAnimation;

  double _previousAlignmentX = -1.0;
  double _currentAlignmentX = -1.0;

  @override
  void initState() {
    super.initState();
    _currentAlignmentX = _getAlignmentForIndex(widget.currentIndex);
    _previousAlignmentX = _currentAlignmentX;

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 440),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 65,
      ),
    ]).animate(_pulseController);

    _plusRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
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
      _pulseController.forward(from: 0.0);
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

    // Stretch-and-squash physics: elongates during flight, then spring rebounds
    _stretchAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.38)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 42,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.38, end: 0.88)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.0)
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
    _pulseController.dispose();
    _plusRotateController.dispose();
    super.dispose();
  }

  void _handlePlusTap() {
    HapticFeedback.mediumImpact();
    _pulseController.forward(from: 0.0);
    _plusRotateController.forward(from: 0.0);
    widget.onReportTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;

    return RepaintBoundary(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
          child: Container(
            height: 68.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                  blurRadius: 28.r,
                  offset: Offset(0, 10.h),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34.r),
                    // Ultra-clear crystal translucency
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              const Color(0xFF1C222D).withValues(alpha: 0.32),
                              const Color(0xFF10141D).withValues(alpha: 0.16),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.08),
                            ],
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.18)
                          : Colors.white.withValues(alpha: 0.75),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Specular top-left bevel glint (اللمعة الكريستالية)
                      Positioned(
                        top: 0,
                        left: 24.w,
                        right: 24.w,
                        height: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                isDark
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : Colors.white.withValues(alpha: 0.90),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Organic Gooey Metaball Melting Bridge (وصلة السائل المذاب)
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _motionController,
                          _pulseController,
                        ]),
                        builder: (context, _) {
                          final currentX = _alignmentAnimation.value;
                          final stretch = _stretchAnimation.value;
                          final pulse = _pulseAnimation.value;
                          final progress = _motionController.value;

                          return CustomPaint(
                            size: Size.infinite,
                            painter: _MetaballMeltingPainter(
                              alignmentX: currentX,
                              stretch: stretch,
                              pulse: pulse,
                              progress: progress,
                              primaryColor: primary,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),

                      // The "Glass Loupe" (عدسة الإزاز) Active Tab Lens
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
                                decoration: BoxDecoration(
                                  // Convex optical lens gradient
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.35, -0.35),
                                    radius: 0.85,
                                    colors: isDark
                                        ? [
                                            Colors.white.withValues(alpha: 0.25),
                                            primary.withValues(alpha: 0.20),
                                            primary.withValues(alpha: 0.06),
                                          ]
                                        : [
                                            Colors.white.withValues(alpha: 0.65),
                                            primary.withValues(alpha: 0.16),
                                            primary.withValues(alpha: 0.04),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : Colors.white.withValues(alpha: 0.85),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withValues(
                                        alpha: isDark ? 0.35 : 0.18,
                                      ),
                                      blurRadius: 12.r,
                                      spreadRadius: -1,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: isDark ? 0.15 : 0.40,
                                      ),
                                      blurRadius: 4.r,
                                      offset: const Offset(-1, -1),
                                    ),
                                  ],
                                ),
                                // Inner convex specular crescent highlight
                                child: Align(
                                  alignment: const Alignment(-0.5, -0.6),
                                  child: Container(
                                    width: 8.r,
                                    height: 4.r,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: isDark ? 0.50 : 0.85,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
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

                          // Center Slot: Melting Point Origin (Report Plus Button)
                          Expanded(
                            child: _CenterMeltingPlusButton(
                              label: l10n.navReport,
                              pulseAnimation: _pulseAnimation,
                              rotateAnimation: _plusRotateController,
                              onTap: _handlePlusTap,
                            ),
                          ),

                          // Tab 2: Notifications
                          Expanded(
                            child: _NavBarItem(
                              icon: Icons.notifications_rounded,
                              label: l10n.navNotifications,
                              isSelected: widget.currentIndex == 2,
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

/// Custom painter that renders the organic gooey metaball connector bridge
/// flowing from the center Plus button (نقطة الدوبان) to the moving Glass Loupe.
class _MetaballMeltingPainter extends CustomPainter {
  _MetaballMeltingPainter({
    required this.alignmentX,
    required this.stretch,
    required this.pulse,
    required this.progress,
    required this.primaryColor,
    required this.isDark,
  });

  final double alignmentX;
  final double stretch;
  final double pulse;
  final double progress;
  final Color primaryColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Convert normalized alignmentX (-1.0 to 1.0) to pixel position
    final slotWidth = size.width / 5;
    final targetX = centerX + (alignmentX * (size.width - slotWidth) / 2);
    final distance = (targetX - centerX).abs();

    // 1. Draw glowing liquid aura around the center Plus melting furnace
    final coreAuraPaint = Paint()
      ..color = primaryColor.withValues(
        alpha: (isDark ? 0.22 : 0.14) + (pulse * 0.16),
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14.r + (pulse * 8.r));

    canvas.drawCircle(Offset(centerX, centerY), 23.r, coreAuraPaint);

    // 2. Draw the organic concave metaball neck bridge
    if (distance > 6.0) {
      final isMovingToLeft = targetX < centerX;

      final bridgePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor.withValues(alpha: isDark ? 0.32 : 0.22),
            primaryColor.withValues(alpha: isDark ? 0.16 : 0.09),
          ],
          begin: Alignment.center,
          end: isMovingToLeft ? Alignment.centerLeft : Alignment.centerRight,
        ).createShader(Rect.fromLTRB(
          math.min(centerX, targetX),
          0,
          math.max(centerX, targetX),
          size.height,
        ))
        ..style = PaintingStyle.fill;

      final path = Path();
      final plusRadius = 22.r;
      final targetRadius = 18.r * stretch;

      // Dynamic concave neck height (thinner during peak stretch, organic taper)
      final midX = (centerX + targetX) / 2;
      final neckPinch = math.max(4.0, 16.0 - (distance / size.width) * 18.0);

      path.moveTo(centerX, centerY - plusRadius);
      path.quadraticBezierTo(
        midX,
        centerY - neckPinch,
        targetX,
        centerY - targetRadius,
      );
      path.lineTo(targetX, centerY + targetRadius);
      path.quadraticBezierTo(
        midX,
        centerY + neckPinch,
        centerX,
        centerY + plusRadius,
      );
      path.close();

      canvas.drawPath(path, bridgePaint);

      // Specular highlight line along the upper liquid bridge rim
      final rimPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: isDark ? 0.35 : 0.70),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(
          math.min(centerX, targetX),
          centerY - 10,
          math.max(centerX, targetX),
          centerY + 10,
        ))
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final rimPath = Path()
        ..moveTo(centerX, centerY - plusRadius)
        ..quadraticBezierTo(
          midX,
          centerY - neckPinch,
          targetX,
          centerY - targetRadius,
        );

      canvas.drawPath(rimPath, rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MetaballMeltingPainter oldDelegate) {
    return oldDelegate.alignmentX != alignmentX ||
        oldDelegate.stretch != stretch ||
        oldDelegate.pulse != pulse ||
        oldDelegate.progress != progress;
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

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

class _CenterMeltingPlusButton extends StatelessWidget {
  const _CenterMeltingPlusButton({
    required this.label,
    required this.pulseAnimation,
    required this.rotateAnimation,
    required this.onTap,
  });

  final String label;
  final Animation<double> pulseAnimation;
  final Animation<double> rotateAnimation;
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
              animation: Listenable.merge([pulseAnimation, rotateAnimation]),
              builder: (context, _) {
                final pulse = pulseAnimation.value;
                final rotation = rotateAnimation.value * (math.pi / 4); // 45 degree spring turn

                return Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4A74FF),
                        Color(0xFF1D4ED8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(
                          alpha: (isDark ? 0.48 : 0.38) + (pulse * 0.22),
                        ),
                        blurRadius: 14.r + (pulse * 6.r),
                        offset: Offset(0, 3.h),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.50),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: rotation,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26.r,
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
