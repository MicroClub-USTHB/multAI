import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_colors.dart';

/// Typography tokens for the app.
abstract class AppThemeTextStyles {
  AppThemeTextStyles._();

  static TextStyle get appBarTitleStyle => GoogleFonts.dmSans(
    color: AppThemeColors.primaryText,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle get inputHintStyle =>
      GoogleFonts.dmSans(color: AppThemeColors.hintText, fontSize: 14);

  static TextStyle get inputLabelStyle => GoogleFonts.dmSans(
    color: AppThemeColors.secondaryText,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get splashLargeText => GoogleFonts.playfairDisplay(
    color: AppThemeColors.primaryText,
    fontSize: 48,
    height: 1.0,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get splashMediumText => GoogleFonts.playfairDisplay(
    color: AppThemeColors.subtitleText,
    fontSize: 18,
    height: 1.55,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get onboardingLargeText => GoogleFonts.dmSans(
    color: AppThemeColors.primaryText,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    fontStyle: FontStyle.normal,
  );

  static TextStyle get onboardingMediumText => GoogleFonts.dmSans(
    color: AppThemeColors.subtitleText,
    fontSize: 18,
    height: 1.5,
    fontStyle: FontStyle.normal,
  );

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
    required Color hint,
  }) => TextTheme(
    displayLarge: GoogleFonts.dmSans(
      color: primary,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.dmSans(
      color: primary,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.4,
    ),
    displaySmall: GoogleFonts.dmSans(
      color: primary,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.3,
    ),
    headlineLarge: GoogleFonts.dmSans(
      color: primary,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.dmSans(
      color: primary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.dmSans(
      color: primary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: GoogleFonts.dmSans(
      color: primary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.dmSans(
      color: primary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.dmSans(
      color: secondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.dmSans(
      color: primary,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.dmSans(
      color: primary,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.dmSans(
      color: secondary,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.dmSans(
      color: primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.dmSans(
      color: secondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.dmSans(
      color: hint,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}
