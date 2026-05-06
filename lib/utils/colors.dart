import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7B68EE);
  static const Color primaryDark = Color(0xFF483D8B);
  static const Color accent = Color(0xFF4169E1);

  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF13132A);
  static const Color surfaceLight = Color(0xFF1A1A35);
  static const Color card = Color(0xFF1E1E40);
  static const Color cardHover = Color(0xFF252550);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0AECF);
  static const Color textMuted = Color(0xFF6B6A8A);

  static const Color success = Color(0xFF4CAF82);
  static const Color error = Color(0xFFFF5C72);
  static const Color warning = Color(0xFFFFB547);

  static const Color divider = Color(0xFF2A2A4A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFF0A0A1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [card, surfaceLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
