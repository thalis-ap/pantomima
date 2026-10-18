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
  static const Color darkElevated = Color(0xFF332759);

  // Light Foundations
  static const Color lightBg = Color(0xFFF7F5FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0ECF9);
  static const Color lightCardBorder = Color(0xFFDDD4F0);
  static const Color lightElevated = Color(0xFFE5DEFA);

  // Brand & Accents
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryViolet = Color(0xFF8B5CF6);
  static const Color electricBlue = Color(0xFF06B6D4);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color vibrantMagenta = Color(0xFFEC4899);
  static const Color brightFuchsia = Color(0xFFD946EF);

  // Semantic & Feedback Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFF34D399);
  static const Color successGreenDark = Color(0xFF059669);

  static const Color passAmber = Color(0xFFF59E0B);
  static const Color passAmberLight = Color(0xFFFBBF24);

  static const Color alertRed = Color(0xFFEF4444);
  static const Color alertRedLight = Color(0xFFF87171);

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

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0xFF3B2875), Color(0xFF22164A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
