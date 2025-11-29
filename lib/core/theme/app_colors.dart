import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryLight = Color(0xFF4791DB);
  static const Color primaryDark = Color(0xFF115293);

  // Secondary Colors
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);

  // Accent
  static const Color accent = Color(0xFFFF6B35);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Match Result Colors
  static const Color win = Color(0xFF4CAF50);
  static const Color draw = Color(0xFF9E9E9E);
  static const Color loss = Color(0xFFF44336);

  // Team Colors (Examples)
  static const Color premierLeague = Color(0xFF3D195B);
  static const Color laLiga = Color(0xFFFF4B44);
  static const Color serieA = Color(0xFF024494);
  static const Color bundesliga = Color(0xFFD20515);
  static const Color ligue1 = Color(0xFF091C3E);
  static const Color kleague = Color(0xFFE60012);
  static const Color ucl = Color(0xFF00085D);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
