import 'package:flutter/material.dart';

/// App color palette precisely aligned with the modern Kenyan party game blueprint.
class AppColors {
  // Midnight OLED Backgrounds
  static const Color darkBackground = Color(0xFF0D0F14);
  static const Color darkCard = Color(0xFF161A22);
  static const Color darkCardBorder = Color(0xFF232A38);
  static const Color darkInput = Color(0xFF1E232E);

  // Light Theme Surfaces
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E9F0);

  // Brand Accents & Aliases
  static const Color savannaGold = Color(0xFFFFC107);
  static const Color neonGreen = Color(0xFF22C55E);
  static const Color forestEmerald = Color(0xFF10B981);
  static const Color coralRed = Color(0xFFEF4444);
  static const Color danger = Color(0xFFEF4444);
  static const Color sunsetOrange = Color(0xFFF97316);
  static const Color electricCyan = Color(0xFF06B6D4);
  static const Color riftCyan = Color(0xFF06B6D4);
  static const Color partyPurple = Color(0xFFA855F7);
  static const Color purpleSherehe = Color(0xFFA855F7);
  static const Color hotPink = Color(0xFFEC4899);
  static const Color maasaiRed = Color(0xFFDC2626);

  // Kenyan Flag Ribbons
  static const Color kenyanGreen = Color(0xFF006600);
  static const Color kenyanRed = Color(0xFF990000);
  static const Color kenyanWhite = Color(0xFFFFFFFF);
  static const Color kenyanBlack = Color(0xFF000000);

  // Text Colors
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);

  // Gradients
  static const LinearGradient cardWordGradient = LinearGradient(
    colors: [
      Color(0xFFE11D48), // Pink Red
      Color(0xFFF59E0B), // Amber
      Color(0xFF10B981), // Emerald
      Color(0xFF3B82F6), // Blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGreenGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF047857), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [savannaGold, sunsetOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient maasaiGradient = LinearGradient(
    colors: [coralRed, sunsetOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [forestEmerald, riftCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shereheGradient = LinearGradient(
    colors: [partyPurple, hotPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gotItGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient passGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
