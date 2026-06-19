import 'package:flutter/cupertino.dart';

/// Zentrale, semantische Farbtokens des Powerplan Dark-Athletic Themes.
abstract class AppColors {
  // Hintergründe / Flächen
  static const Color background = Color(0xFF0E0F12);
  static const Color surface = Color(0xFF16181D);
  static const Color surfaceElevated = Color(0xFF1E2127);
  static const Color border = Color(0xFF2A2E36);
  static const Color divider = Color(0xFF22252B);

  // Text
  static const Color textPrimary = Color(0xFFF5F6F8);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color textMuted = Color(0xFF6B7177);

  // Akzent (Energetic Orange)
  static const Color accent = Color(0xFFFF6B1A);
  static const Color accentMuted = Color(0x33FF6B1A); // 20% Orange
  static const Color accentSoft = Color(0x14FF6B1A); // 8% Orange

  // Semantische Status-Farben (dunkel-tauglich)
  static const Color success = Color(0xFF34C759);
  static const Color successSoft = Color(0x2634C759);
  static const Color warning = Color(0xFFFFB020);
  static const Color warningSoft = Color(0x26FFB020);
  static const Color danger = Color(0xFFFF453A);
  static const Color dangerSoft = Color(0x26FF453A);
  static const Color info = Color(0xFF0A84FF);
  static const Color infoSoft = Color(0x260A84FF);

  // Universelles Weiß für On-Accent
  static const Color onAccent = Color(0xFFFFFFFF);
}
