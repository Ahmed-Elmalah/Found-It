import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF0F1218);

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2F5BEA),
    onPrimary: Colors.white,
    secondary: Color(0xFF2F5BEA),
    onSecondary: Colors.white,
    error: Color(0xFFC4281C),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF14171F),
    onSurfaceVariant: Color(0xFF565D6C),
    outline: Color(0xFFE1E5EE),
    surfaceContainerHighest: Color(0xFFE7EAF3),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8FA8FF),
    onPrimary: Color(0xFF0F1218),
    secondary: Color(0xFF8FA8FF),
    onSecondary: Color(0xFF0F1218),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF0F1218),
    surface: Color(0xFF1A1F29),
    onSurface: Color(0xFFECEFF4),
    onSurfaceVariant: Color(0xFFA3ABBA),
    outline: Color(0xFF2C3342),
    surfaceContainerHighest: Color(0xFF252B38),
  );

  // 'Found' (success) has no token in the schemes above, so it gets its own
  // light / dark pair. Used by the report status colors (see ReportStatus).
  static const Color successLight = Color(0xFF047857);
  static const Color successDark = Color(0xFF6EE7B7);
}
