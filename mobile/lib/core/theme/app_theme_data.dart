import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_colors.dart';
import 'app_theme_colors_light.dart';
import 'app_theme_metrics.dart';
import 'app_theme_text_styles.dart';

/// ThemeData factory for the app.
abstract class AppThemeData {
  AppThemeData._();

  // ── Dark Theme (existing) ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: AppThemeColors.primaryAccent,
      scaffoldBackgroundColor: AppThemeColors.background,
      cardColor: AppThemeColors.card,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: AppThemeColors.primaryAccent,
        secondary: AppThemeColors.secondaryAccent,
        surface: AppThemeColors.surface,
        surfaceContainerHighest: AppThemeColors.surfaceHigh,
        error: AppThemeColors.error,
        outline: AppThemeColors.inputBorder,
        outlineVariant: AppThemeColors.border,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppThemeColors.primaryText,
        onSurfaceVariant: AppThemeColors.secondaryText,
        onError: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppThemeColors.background,
        foregroundColor: AppThemeColors.primaryText,
        elevation: AppThemeMetrics.elevationNone,
        scrolledUnderElevation: AppThemeMetrics.elevationNone,
        centerTitle: false,
        titleTextStyle: AppThemeTextStyles.appBarTitleStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.button,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppThemeColors.button.withValues(
            alpha: AppThemeMetrics.opacityDisabled,
          ),
          disabledForegroundColor: Colors.white70,
          elevation: AppThemeMetrics.elevationNone,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppThemeColors.primaryText,
          side: const BorderSide(
            color: AppThemeColors.inputBorder,
            width: AppThemeMetrics.borderThick,
          ),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
          backgroundColor: Colors.transparent,
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppThemeColors.primaryAccent,
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      textTheme: AppThemeTextStyles.textTheme(
        primary: AppThemeColors.primaryText,
        secondary: AppThemeColors.secondaryText,
        hint: AppThemeColors.hintText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _inputBorder(AppThemeColors.inputBorder),
        enabledBorder: _inputBorder(AppThemeColors.inputBorder),
        focusedBorder: _inputBorder(
          AppThemeColors.primaryAccent,
          width: AppThemeMetrics.borderFocus,
        ),
        errorBorder: _inputBorder(AppThemeColors.error),
        focusedErrorBorder: _inputBorder(
          AppThemeColors.error,
          width: AppThemeMetrics.borderFocus,
        ),
        filled: true,
        fillColor: AppThemeColors.inputFill,
        hintStyle: AppThemeTextStyles.inputHintStyle,
        labelStyle: AppThemeTextStyles.inputLabelStyle,
        prefixIconColor: AppThemeColors.hintText,
        suffixIconColor: AppThemeColors.hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppThemeMetrics.spacingMd,
          vertical: AppThemeMetrics.spacingMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppThemeColors.card,
        elevation: AppThemeMetrics.elevationNone,
        shadowColor: AppThemeColors.shadowSoft,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          side: const BorderSide(
            color: AppThemeColors.activeCardBorder,
            width: AppThemeMetrics.borderHairline,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppThemeColors.surface,
        selectedColor: AppThemeColors.selected,
        side: const BorderSide(
          color: AppThemeColors.inputBorder,
          width: AppThemeMetrics.borderHairline,
        ),
        labelStyle: AppThemeTextStyles.textTheme(
          primary: AppThemeColors.primaryText,
          secondary: AppThemeColors.secondaryText,
          hint: AppThemeColors.hintText,
        ).labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppThemeColors.surfaceHigh,
        contentTextStyle: AppThemeTextStyles.textTheme(
          primary: AppThemeColors.primaryText,
          secondary: AppThemeColors.secondaryText,
          hint: AppThemeColors.hintText,
        ).bodyMedium,
        actionTextColor: AppThemeColors.primaryAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppThemeColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppThemeColors.inputBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppThemeMetrics.radiusXxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppThemeColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppThemeMetrics.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusXl),
        ),
        titleTextStyle: AppThemeTextStyles.textTheme(
          primary: AppThemeColors.primaryText,
          secondary: AppThemeColors.secondaryText,
          hint: AppThemeColors.hintText,
        ).headlineSmall,
        contentTextStyle: AppThemeTextStyles.textTheme(
          primary: AppThemeColors.primaryText,
          secondary: AppThemeColors.secondaryText,
          hint: AppThemeColors.hintText,
        ).bodyMedium,
      ),
      dividerTheme: const DividerThemeData(
        color: AppThemeColors.divider,
        thickness: AppThemeMetrics.borderHairline,
        space: AppThemeMetrics.spacingMd,
      ),
      iconTheme: const IconThemeData(
        color: AppThemeColors.secondaryText,
        size: AppThemeMetrics.iconMd,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppThemeColors.primaryAccent,
        linearTrackColor: AppThemeColors.inputBorder,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: AppThemeColorsLight.primaryAccent,
      scaffoldBackgroundColor: AppThemeColorsLight.background,
      cardColor: AppThemeColorsLight.card,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: AppThemeColorsLight.primaryAccent,
        secondary: AppThemeColorsLight.secondaryAccent,
        surface: AppThemeColorsLight.surface,
        surfaceContainerHighest: AppThemeColorsLight.surfaceHigh,
        error: AppThemeColorsLight.error,
        outline: AppThemeColorsLight.inputBorder,
        outlineVariant: AppThemeColorsLight.border,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppThemeColorsLight.primaryText,
        onSurfaceVariant: AppThemeColorsLight.secondaryText,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppThemeColorsLight.background,
        foregroundColor: AppThemeColorsLight.primaryText,
        elevation: AppThemeMetrics.elevationNone,
        scrolledUnderElevation: AppThemeMetrics.elevationNone,
        centerTitle: false,
        titleTextStyle: GoogleFonts.raleway(
          color: AppThemeColorsLight.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColorsLight.button,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppThemeColorsLight.button.withValues(
            alpha: AppThemeMetrics.opacityDisabled,
          ),
          disabledForegroundColor: Colors.white70,
          elevation: AppThemeMetrics.elevationNone,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppThemeColorsLight.primaryText,
          side: const BorderSide(
            color: AppThemeColorsLight.inputBorder,
            width: AppThemeMetrics.borderThick,
          ),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
          backgroundColor: Colors.transparent,
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppThemeColorsLight.primaryAccent,
          textStyle: AppThemeTextStyles.buttonTextStyle,
        ),
      ),
      textTheme: _lightTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        border: _inputBorder(AppThemeColorsLight.inputBorder),
        enabledBorder: _inputBorder(AppThemeColorsLight.inputBorder),
        focusedBorder: _inputBorder(
          AppThemeColorsLight.primaryAccent,
          width: AppThemeMetrics.borderFocus,
        ),
        errorBorder: _inputBorder(AppThemeColorsLight.error),
        focusedErrorBorder: _inputBorder(
          AppThemeColorsLight.error,
          width: AppThemeMetrics.borderFocus,
        ),
        filled: true,
        fillColor: AppThemeColorsLight.inputFill,
        hintStyle: GoogleFonts.montserrat(
          color: AppThemeColorsLight.hintText,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.raleway(
          color: AppThemeColorsLight.secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppThemeColorsLight.hintText,
        suffixIconColor: AppThemeColorsLight.hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppThemeMetrics.spacingMd,
          vertical: AppThemeMetrics.spacingMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppThemeColorsLight.card,
        elevation: AppThemeMetrics.elevationNone,
        shadowColor: AppThemeColorsLight.shadowSoft,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          side: BorderSide(
            color: AppThemeColorsLight.neutral600,
            width: AppThemeMetrics.borderHairline,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppThemeColorsLight.surface,
        selectedColor: AppThemeColorsLight.selected,
        side: const BorderSide(
          color: AppThemeColorsLight.inputBorder,
          width: AppThemeMetrics.borderHairline,
        ),
        labelStyle: GoogleFonts.raleway(
          color: AppThemeColorsLight.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppThemeColorsLight.surfaceHigh,
        contentTextStyle: GoogleFonts.montserrat(
          color: AppThemeColorsLight.primaryText,
          fontSize: 16,
        ),
        actionTextColor: AppThemeColorsLight.primaryAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppThemeColorsLight.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppThemeColorsLight.inputBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppThemeMetrics.radiusXxl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppThemeColorsLight.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppThemeMetrics.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusXl),
        ),
        titleTextStyle: GoogleFonts.raleway(
          color: AppThemeColorsLight.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.montserrat(
          color: AppThemeColorsLight.primaryText,
          fontSize: 16,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppThemeColorsLight.divider,
        thickness: AppThemeMetrics.borderHairline,
        space: AppThemeMetrics.spacingMd,
      ),
      iconTheme: const IconThemeData(
        color: AppThemeColorsLight.secondaryText,
        size: AppThemeMetrics.iconMd,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppThemeColorsLight.primaryAccent,
        linearTrackColor: AppThemeColorsLight.inputBorder,
      ),
    );
  }

  static TextTheme get _lightTextTheme => TextTheme(
    displayLarge: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      height: 1.2,
      letterSpacing: -0.4,
    ),
    displaySmall: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.3,
    ),
    headlineLarge: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleLarge: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.raleway(
      color: AppThemeColorsLight.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.montserrat(
      color: AppThemeColorsLight.primaryText,
      fontSize: 18,
      fontWeight: FontWeight.normal,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.montserrat(
      color: AppThemeColorsLight.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.raleway(
      color: AppThemeColorsLight.secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.4,
    ),
    labelLarge: GoogleFonts.raleway(
      color: AppThemeColorsLight.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.raleway(
      color: AppThemeColorsLight.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.raleway(
      color: AppThemeColorsLight.hintText,
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  static OutlineInputBorder _inputBorder(
    Color color, {
    double width = AppThemeMetrics.borderThin,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
