import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Radius ─────────────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 18.0;

  // ── Spacing ────────────────────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 40.0;

  // ── Primary Colors ─────────────────────────────────────────────────────────
  static const Color primaryColor = Color(
    0xFFE8A020,
  ); // Golden/amber accent from palette
  static const Color secondaryColor = Color(
    0xFFD4901A,
  ); // Darker golden for secondary
  static const Color accentColor = Color(0xFFFFB830); // Bright golden highlight

  // ── Background Colors ──────────────────────────────────────────────────────
  static const Color backgroundColor = Color(
    0xFF1A1008,
  ); // Very dark brown/black background
  static const Color surfaceColor = Color(
    0xFF2A1E0F,
  ); // Slightly lighter dark brown surface
  static const Color cardColor = Color(
    0xFF2A1E0F,
  ); // Dark brown card background

  // ── Text Colors ────────────────────────────────────────────────────────────
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White primary text
  static const Color secondaryTextColor = Color(0xFFB0A090); // Muted warm gray
  static const Color hintTextColor = Color(0xFF7A6A5A); // Dim warm gray hints

  // ── Splash Colors ─────────────────────────────────────────────────────
  static const Color splashBackgroundColor = Color(0xFF0F0E0D);
  static const Color gold = Color(0xFFE8A830); // The "Ai" color
  static const Color slateGray = Color(0xFF94A3B8); // The subtitle color
  static const Color textDevider = Color(0xFF64748B);
  static const Color devider = Color(0xFF1E293B);
  static const Color gradient = Color(0x33E8A830);

  // ── Onboarding Colors ─────────────────────────────────────────────────────
  static const Color onboardingBackgroundColor = Color(0xFF221610);

  // ── Interactive Colors ─────────────────────────────────────────────────────
  static const Color buttonColor = Color(0xFFE8A020); // Golden button color
  static const Color selectedColor = Color(
    0xFF3A2A15,
  ); // Slightly highlighted dark brown
  static const Color borderColor = Color(
    0xFF3D2E1A,
  ); // Subtle dark brown border

  // ── Input Field Colors ─────────────────────────────────────────────────────
  static const Color inputFillColor = Color(
    0xFF231809,
  ); // Very dark brown for inputs
  static const Color inputBorderColor = Color(
    0xFF4A3820,
  ); // Slightly visible border
  // ── Form Card Color ────────────────────────────────────────────────────────
  static const Color formCardColor = Color(
    0x1AE8A830,
  ); // #E8A8301A amber with low opacity

  // ── Status Colors ──────────────────────────────────────────────────────────
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFFE8A020);

  // ── Reading Colors ─────────────────────────────────────────────────────────
  static const Color readingBackgroundColor = Color(0xFF1A1008);
  static const Color highlightColor = Color(0xFFFFEB3B);
  static const Color bookmarkColor = Color(0xFFE8A020);

  // ── Social Colors ──────────────────────────────────────────────────────────
  static const Color googleColor = Color(0xFF4285F4);
  static const Color appleColor = Color(0xFFFFFFFF);

  // ── Transparent Colors ─────────────────────────────────────────────────────
  static const Color overlayColor = Color(0x80000000);
  static const Color shimmerColor = Color(0xFF3A2A15);
  // colors ____________________________________________________________________
  static const Color photoSlotColor      = Color(0xFF334155);
  static const Color tipsBgColor         = Color(0x1A64748B);
  static const Color enrollDisabledColor = Color(0x33EC5B13);

  // ── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: primaryTextColor,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.raleway(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTextColor,
          side: const BorderSide(color: inputBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          backgroundColor: surfaceColor,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.raleway(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: primaryTextColor,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.raleway(
          color: secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.raleway(
          color: primaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.raleway(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.raleway(
          color: hintTextColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: inputFillColor,
        hintStyle: GoogleFonts.montserrat(color: hintTextColor, fontSize: 14),
        labelStyle: GoogleFonts.raleway(
          color: secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: hintTextColor,
        suffixIconColor: hintTextColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: inputBorderColor, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: inputBorderColor,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(color: secondaryTextColor),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: inputBorderColor,
      ),
    );
  }

  // ── spalsh style ─────────────────────────────────────────────────────────────
  static TextStyle splashLargeText = GoogleFonts.playfairDisplay(
    color: primaryTextColor,
    fontSize: 48,
    height: 1.0,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
  );
  static TextStyle splashMediumText = GoogleFonts.playfairDisplay(
    color: slateGray,
    fontSize: 18,
    height: 1.55,
    fontStyle: FontStyle.italic,
  );
  // ── spalsh style ─────────────────────────────────────────────────────────────
  static TextStyle onbaordingLargeText = GoogleFonts.publicSans(
    color: primaryTextColor,
    fontSize: 36,
    fontStyle: FontStyle.normal,
  );
  static TextStyle onbaordingMediumText = GoogleFonts.publicSans(
    color: slateGray,
    fontSize: 18,
    fontStyle: FontStyle.normal,
  );

  static ThemeData get darkTheme => lightTheme;
}
