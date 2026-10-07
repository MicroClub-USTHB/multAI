import 'package:flutter/material.dart';

/// Light-mode color palette.
abstract class AppThemeColorsLight {
  AppThemeColorsLight._();

  // Accent: same electric indigo across both modes.
  static const Color primaryAccent = Color(0xFF6E56F8);
  static const Color secondaryAccent = Color(0xFF5B44E0);
  static const Color accent = Color(0xFF8B78FF);

  // Neutral ramp for light mode (higher values = darker).
  static const Color neutral0 = Color(0xFF08080B);
  static const Color neutral100 = Color(0xFF1A1A2E);
  static const Color neutral200 = Color(0xFF3A3A4A);
  static const Color neutral300 = Color(0xFF6B6B78);
  static const Color neutral400 = Color(0xFF9A9AA6);
  static const Color neutral500 = Color(0xFFBDBDC8);
  static const Color neutral600 = Color(0xFFD4D4DC);
  static const Color neutral700 = Color(0xFFE8E8EE);
  static const Color neutral800 = Color(0xFFF0F0F4);
  static const Color neutral850 = Color(0xFFF5F5F8);
  static const Color neutral900 = Color(0xFFFAFAFC);
  static const Color neutral950 = Color(0xFFFFFFFF);

  // Surfaces and backgrounds.
  static const Color background = neutral900;
  static const Color surface = neutral950;
  static const Color surfaceHigh = neutral850;
  static const Color card = neutral950;

  // Text colors.
  static const Color primaryText = neutral0;
  static const Color secondaryText = neutral200;
  static const Color hintText = neutral400;
  static const Color subtitleText = neutral300;

  // UI elements.
  static const Color divider = neutral700;
  static const Color inputFill = neutral850;
  static const Color inputBorder = neutral600;
  static const Color border = neutral600;
  static const Color selected = Color(0x1A6E56F8);

  // Status colors.
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = primaryAccent;

  // Interactive elements.
  static const Color button = primaryAccent;

  // Shadows.
  static const Color shadowSoft = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color tabUnselectedText = neutral300;
}
