import 'package:flutter/material.dart';

/// Centralized color palette for the app.
///
/// The system is built on one warm, dark "candlelit gold" identity. Every
/// surface, border and muted text tone is tuned to the same warm temperature so
/// the splash, auth and gallery screens read as a single product, not three.
abstract class AppThemeColors {
  AppThemeColors._();

  // Primary palette.
  static const Color primaryAccent = Color(0xFFE8A020);
  static const Color secondaryAccent = Color(0xFFD4901A);
  static const Color accent = Color(0xFFFFB830);

  // Warm neutral ramp. A single tonal family that backs every dark surface and
  // muted text tone. Lower numbers are deeper, higher numbers are lighter.
  static const Color neutral950 = Color(0xFF150D06);
  static const Color neutral900 = Color(0xFF1A1008);
  static const Color neutral850 = Color(0xFF1F1610);
  static const Color neutral800 = Color(0xFF241813);
  static const Color neutral700 = Color(0xFF2E2016);
  static const Color neutral600 = Color(0xFF3A2A18);
  static const Color neutral500 = Color(0xFF4A3820);
  static const Color neutral300 = Color(0xFF7A6A5A);
  static const Color neutral200 = Color(0xFFA89A88);
  static const Color neutral100 = Color(0xFFB0A090);
  static const Color neutral0 = Color(0xFFFFFFFF);

  // Surfaces and backgrounds.
  static const Color background = neutral900;
  static const Color surface = neutral800;
  static const Color surfaceHigh = neutral700;
  static const Color card = neutral800;
  static const Color onboardingBackground = Color(0xFF221610);
  static const Color splashBackground = Color(0xFF0F0E0D);
  static const Color readingBackground = neutral900;

  // Event cards. Warmed from the original cool slate so the gallery shares the
  // same temperature as the rest of the app.
  static const Color activeCardBackground = neutral800;
  static const Color activeCardBorder = neutral600;
  static const Color archivedCardBackground = neutral850;
  static const Color archivedCardBorder = neutral700;
  static const Color cardDateText = neutral200;
  static const Color archivedTitle = Color(0xFF9A8B78);
  static const Color archivedDate = neutral300;

  static const double activeCardBackgroundOpacity = 0.4;
  static const double archivedCardBackgroundOpacity = 0.1;
  static const double archivedCardBorderOpacity = 0.4;

  // Text colors.
  static const Color primaryText = neutral0;
  static const Color secondaryText = neutral100;
  static const Color hintText = neutral300;
  static const Color subtitleText = neutral200;

  // Splash and onboarding accents.
  static const Color gold = Color(0xFFE8A830);
  static const Color dividerText = neutral300;
  static const Color divider = neutral700;
  static const Color gradientOverlay = Color(0x33E8A830);

  // Gold gradient stops for premium buttons and headers.
  static const Color gradientGoldStart = Color(0xFFFFB830);
  static const Color gradientGoldEnd = Color(0xFFD4901A);

  // Warm scrim for image-behind-text treatments (fades photos into the base).
  static const Color scrim = Color(0xCC150D06);

  // Interactive elements.
  static const Color button = primaryAccent;
  static const Color selected = Color(0xFF3A2A15);
  static const Color border = Color(0xFF3D2E1A);
  static const Color inputFill = Color(0xFF231809);
  static const Color inputBorder = neutral500;
  static const Color formCard = Color(0x1AE8A830);

  // Status colors.
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = primaryAccent;
  static const Color activeEventDot = Color(0xFF22C55E);

  // Utility colors.
  static const Color highlight = Color(0xFFFFEB3B);
  static const Color bookmark = primaryAccent;
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFF3A2A15);
  static const Color photoSlot = neutral600;
  static const Color tipsBackground = Color(0x1AB0A090);
  static const Color enrollDisabled = Color(0x33EC5B13);

  // Elevation shadows, tuned soft for a dark UI.
  static const Color shadowSoft = Color(0x33000000);
  static const Color shadowMedium = Color(0x4D000000);

  // Tabs.
  static const Color tabUnselectedText = neutral200;
  static const Color tabDivider = Color.fromRGBO(255, 255, 255, 0.1);
}
