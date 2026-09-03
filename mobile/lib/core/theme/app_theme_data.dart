import 'package:flutter/material.dart';

import 'app_theme_colors.dart';
import 'app_theme_metrics.dart';
import 'app_theme_text_styles.dart';

/// ThemeData factory for the app.
abstract class AppThemeData {
  AppThemeData._();

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

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,

      primaryColor: AppThemeColors.primaryAccent,

      // Soft off-white canvas rather than pure white.
      scaffoldBackgroundColor: const Color(0xFFF7F7F8),
      cardColor: Colors.white,

      colorScheme: const ColorScheme.light(
        primary: AppThemeColors.primaryAccent,
        secondary: AppThemeColors.secondaryAccent,

        // Main surfaces.
        surface: Colors.white,
        surfaceContainerHighest: Color(0xFFF0F0F2),

        // Text.
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF18181B),
        onSurfaceVariant: Color(0xFF52525B),

        // States.
        error: AppThemeColors.error,
        onError: Colors.white,

        // Borders.
        outline: Color(0xFFD4D4D8),
        outlineVariant: Color(0xFFE4E4E7),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F7F8),
        foregroundColor: Color(0xFF18181B),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      textTheme: AppThemeTextStyles.textTheme(
        primary: const Color(0xFF18181B),
        secondary: const Color(0xFF52525B),
        hint: const Color(0xFF71717A),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusLg),
          side: const BorderSide(
            color: Color(0xFFE4E4E7),
            width: AppThemeMetrics.borderHairline,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFFE4E4E7),
        thickness: AppThemeMetrics.borderHairline,
        space: AppThemeMetrics.spacingMd,
      ),

      iconTheme: const IconThemeData(
        color: Color(0xFF52525B),
        size: AppThemeMetrics.iconMd,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        // Much softer than neutral100 (#C4C4CE).
        fillColor: Color(0xFFF0F0F2),

        border: _inputBorder(const Color(0xFFD4D4D8)),

        enabledBorder: _inputBorder(const Color(0xFFD4D4D8)),

        focusedBorder: _inputBorder(
          AppThemeColors.primaryAccent,
          width: AppThemeMetrics.borderFocus,
        ),

        hintStyle: const TextStyle(color: Color(0xFF71717A)),

        labelStyle: const TextStyle(color: Color(0xFF52525B)),

        prefixIconColor: const Color(0xFF71717A),
        suffixIconColor: const Color(0xFF71717A),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppThemeColors.primaryAccent,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeColors.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF27272A),
          side: const BorderSide(color: Color(0xFFD4D4D8)),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFF18181B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(0xFF52525B),
          fontSize: 16,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF27272A),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: AppThemeColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: Color(0xFFD4D4D8),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F0F2),
        selectedColor: const Color(0xFFE9E6FF),
        side: const BorderSide(
          color: Color(0xFFE4E4E7),
          width: AppThemeMetrics.borderHairline,
        ),
        labelStyle: const TextStyle(color: Color(0xFF52525B)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusPill),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppThemeColors.primaryAccent,
        linearTrackColor: Color(0xFFE4E4E7),
      ),
    );
  }

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
