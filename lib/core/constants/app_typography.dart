import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typographic system for CHEZA! based on Google Font 'Outfit'.
class AppTypography {
  // Display Level (32-48px)
  static TextStyle displayLarge = GoogleFonts.outfit(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle displayMedium = GoogleFonts.outfit(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: -0.2,
    height: 1.15,
  );

  static TextStyle displaySmall = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle gameTitle = GoogleFonts.outfit(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: 1.5,
    height: 1.05,
  );

  static TextStyle gameWordCard = GoogleFonts.outfit(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: 0.5,
    height: 1.1,
  );

  // Screen & Section Headings (18-24px)
  static TextStyle h1 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    letterSpacing: -0.2,
  );

  static TextStyle h2 = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );

  static TextStyle h3 = GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: 0.1,
  );

  // Body & Content (14-16px)
  static TextStyle bodyLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.35,
  );

  static TextStyle bodySmall = GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.3,
  );

  // Action Buttons & Badges (12-16px)
  static TextStyle buttonLarge = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: AppColors.textLight,
    letterSpacing: 0.8,
  );

  static TextStyle buttonMedium = GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static TextStyle badge = GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.8,
  );

  static TextStyle micro = GoogleFonts.outfit(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.textMuted,
    letterSpacing: 1.0,
  );
}
