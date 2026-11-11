import 'package:flutter/material.dart';


abstract final class AppColors {
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF141923);

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2B66FF),
    onPrimary: Colors.white,
    secondary: Color(0xFF2B66FF),
    onSecondary: Colors.white,
    error: Color(0xFFDC2626),
    onError: Colors.white,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFEEF2F6),
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF8EA8FE),
    onPrimary: Color(0xFF0C1018),
    secondary: Color(0xFF8EA8FE),
    onSecondary: Color(0xFF0C1018),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    surface: Color(0xFF2B3144),
    onSurface: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF384056),
    surfaceContainerHighest: Color(0xFF1F2536),
  );
}