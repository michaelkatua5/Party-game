import 'package:flutter/material.dart';

/// Centralized color system for CHEZA! — Premium Kenyan Party Game.
/// Deep midnight OLED backgrounds with vibrant neon accents and party gradients.
class AppColors {
  // Midnight OLED Backgrounds
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF10141D);
  static const Color darkCard = Color(0xFF161B26);
  static const Color darkCardHover = Color(0xFF1F2636);
  static const Color darkCardBorder = Color(0xFF252D3D);
  static const Color darkInput = Color(0xFF1A212E);

  // Light Theme Surfaces (Fallback)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E9F0);

  // Core Brand Neon Accents
  static const Color savannaGold = Color(0xFFFFB800);
  static const Color neonGreen = Color(0xFF2ED573);
  static const Color forestEmerald = Color(0xFF10B981);
  static const Color coralRed = Color(0xFFFF4757);
  static const Color danger = Color(0xFFFF4757);
  static const Color sunsetOrange = Color(0xFFFF793F);
  static const Color electricCyan = Color(0xFF00F0FF);
  static const Color riftCyan = Color(0xFF06B6D4);
  static const Color partyPurple = Color(0xFF8A2BE2);
  static const Color purpleSherehe = Color(0xFFA855F7);
  static const Color hotPink = Color(0xFFFF1493);
  static const Color cyberPink = Color(0xFFFF007F);
  static const Color maasaiRed = Color(0xFFDC2626);

  // Subtle Kenyan Flag Accents
  static const Color kenyanGreen = Color(0xFF006600);
  static const Color kenyanRed = Color(0xFF990000);
  static const Color kenyanWhite = Color(0xFFFFFFFF);
  static const Color kenyanBlack = Color(0xFF000000);

  // Text Colors
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E9BAE);
  static const Color textDark = Color(0xFF0F172A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF793F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient quickPlayGradient = LinearGradient(
    colors: [Color(0xFF2ED573), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient partyGradient = LinearGradient(
    colors: [Color(0xFFFF007F), Color(0xFF8A2BE2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient kingsCupGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient practiceGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardWordGradient = LinearGradient(
    colors: [
      Color(0xFFFF007F), // Neon Pink
      Color(0xFFFFB800), // Gold
      Color(0xFF2ED573), // Lime Green
      Color(0xFF00F0FF), // Cyan
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient maasaiGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF793F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF00F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shereheGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFFF1493)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGreenGradient = LinearGradient(
    colors: [Color(0xFF0A2E20), Color(0xFF0F4731), Color(0xFF135A3E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gotItGradient = LinearGradient(
    colors: [Color(0xFF2ED573), Color(0xFF20BF6B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient passGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFEB3B5A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
