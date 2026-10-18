import 'package:flutter/material.dart';

/// Curated color palette for «Παντομίμα»
/// Rich deep violet, indigo, electric accents, emerald green, and alert coral.
class AppColors {
  AppColors._();

  // Dark Foundations
  static const Color darkBg = Color(0xFF0F0B1E);
  static const Color darkSurface = Color(0xFF1B1433);
  static const Color darkCard = Color(0xFF261D47);
  static const Color darkCardBorder = Color(0xFF3B2E68);

  // Light Foundations
  static const Color lightBg = Color(0xFFF7F5FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0ECF9);
  static const Color lightCardBorder = Color(0xFFDDD4F0);

  // Brand & Accents
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryViolet = Color(0xFF8B5CF6);
  static const Color electricBlue = Color(0xFF06B6D4);
  static const Color vibrantMagenta = Color(0xFFEC4899);

  // Semantic & Feedback Colors
  static const Color passAmber = Color(0xFFF59E0B);
  static const Color alertRed = Color(0xFFEF4444);

  // Difficulty Badges
  static const Color diffEasy = Color(0xFF10B981); // Emerald
  static const Color diffMedium = Color(0xFF06B6D4); // Cyan
  static const Color diffHard = Color(0xFFF59E0B); // Amber
  static const Color diffImpossible = Color(0xFFEC4899); // Fuchsia

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient passGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
