import 'package:flutter/material.dart';

/// The thin line icons used in the design (Lucide style, 24 x 24 grid).
enum LineIconType { search, searchCheck, plus, messageCircle }

/// Draws a design line icon at any size and color, crisp on every screen.
///
///   LineIcon(LineIconType.search, size: 120.r, color: colors.primary)
///
/// [strokeWidth] is in the 24-unit grid (2 = the normal Lucide weight),
/// so the line gets thicker together with [size].
class LineIcon extends StatelessWidget {
  const LineIcon(
    this.type, {
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2,
  });

  final LineIconType type;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _LineIconPainter(type, color, strokeWidth),
      ),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  _LineIconPainter(this.type, this.color, this.strokeWidth);

  final LineIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in the 24 x 24 grid of the original icon, scaled to [size].
    canvas.scale(size.width / 24, size.height / 24);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (type) {
      case LineIconType.search:
        _search(canvas, paint);
      case LineIconType.searchCheck:
        _search(canvas, paint);
        canvas.drawPath(
          Path()
            ..moveTo(8, 11)
            ..lineTo(10, 13)
            ..lineTo(14, 9),
          paint,
        );
      case LineIconType.plus:
        canvas
          ..drawLine(const Offset(5, 12), const Offset(19, 12), paint)
          ..drawLine(const Offset(12, 5), const Offset(12, 19), paint);
      case LineIconType.messageCircle:
        // SVG: M7.9 20 A9 9 0 1 0 4 16.1 L2 22 Z
        canvas.drawPath(
          Path()
            ..moveTo(7.9, 20)
            ..arcToPoint(
              const Offset(4, 16.1),
              radius: const Radius.circular(9),
              largeArc: true,
              clockwise: false,
            )
            ..lineTo(2, 22)
            ..close(),
          paint,
        );
    }
  }

  void _search(Canvas canvas, Paint paint) {
    canvas
      ..drawCircle(const Offset(11, 11), 8, paint)
      ..drawLine(const Offset(21, 21), const Offset(16.65, 16.65), paint);
  }

  @override
  bool shouldRepaint(_LineIconPainter old) =>
      old.type != type || old.color != color || old.strokeWidth != strokeWidth;
}
