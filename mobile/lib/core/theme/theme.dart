import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Based on MultiAi color palette
  static const Color primaryColor =
      Color(0xFFE8A020); // Golden/amber accent from palette
  static const Color secondaryColor =
      Color(0xFFD4901A); // Darker golden for secondary
  static const Color accentColor =
      Color(0xFFFFB830); // Bright golden highlight

  // Background Colors
  static const Color backgroundColor =
      Color(0xFF1A1008); // Very dark brown/black background
  static const Color surfaceColor =
      Color(0xFF2A1E0F); // Slightly lighter dark brown surface
  static const Color cardColor =
      Color(0xFF2A1E0F); // Dark brown card background

  // Text Colors
  static const Color primaryTextColor =
      Color(0xFFFFFFFF); // White primary text
  static const Color secondaryTextColor =
      Color(0xFFB0A090); // Muted warm gray
  static const Color hintTextColor =
      Color(0xFF7A6A5A); // Dim warm gray hints

  // Interactive Colors
  static const Color buttonColor =
      Color(0xFFE8A020); // Golden button color
  static const Color selectedColor =
      Color(0xFF3A2A15); // Slightly highlighted dark brown
  static const Color borderColor =
      Color(0xFF3D2E1A); // Subtle dark brown border

  // Input Field Colors
  static const Color inputFillColor =
      Color(0xFF231809); // Very dark brown for inputs
  static const Color inputBorderColor =
      Color(0xFF4A3820); // Slightly visible border

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green success
  static const Color errorColor = Color(0xFFD32F2F); // Red error
  static const Color warningColor = Color(0xFFFF9800); // Orange warning
  static const Color infoColor = Color(0xFFE8A020); // Golden info

  // Reading-focused Colors
  static const Color readingBackgroundColor =
      Color(0xFF1A1008); // Dark background for reading
  static const Color highlightColor =
      Color(0xFFFFEB3B); // Yellow highlight
  static const Color bookmarkColor =
      Color(0xFFE8A020); // Golden bookmark

  // Social Colors
  static const Color googleColor = Color(0xFF4285F4);
  static const Color appleColor = Color(0xFFFFFFFF);

  // Transparent Colors
  static const Color overlayColor = Color(0x80000000);
  static const Color shimmerColor = Color(0xFF3A2A15);

  // Theme Data
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
            borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: surfaceColor,
        ),
      ),
      textTheme: TextTheme(
        // Display styles - For major headings
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

        // Headline styles - For section headings
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

        // Title styles - For UI elements
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

        // Body styles
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

        // Label styles - For buttons and small UI elements
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
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: inputFillColor,
        hintStyle: GoogleFonts.montserrat(
          color: hintTextColor,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.raleway(
          color: secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: hintTextColor,
        suffixIconColor: hintTextColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: inputBorderColor, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: inputBorderColor,
        thickness: 0.5,
      ),
      iconTheme: const IconThemeData(
        color: secondaryTextColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: inputBorderColor,
      ),
    );
  }
  static ThemeData get darkTheme {
    return lightTheme;
  }
}