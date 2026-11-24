import 'package:flutter/material.dart';

import 'app_theme_colors.dart';
import 'app_theme_colors_light.dart';

/// A complete, mode-aware color palette.
///
/// Screens should read colors from [AppPalette] through the `context.colors`
/// extension instead of referencing [AppThemeColors] (the dark palette)
/// directly. That way every widget repaints correctly when the app switches
/// between dark and light mode.
@immutable
class AppPalette {
  const AppPalette({
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.accent,
    required this.neutral0,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.neutral850,
    required this.neutral900,
    required this.neutral950,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.card,
    required this.onboardingBackground,
    required this.splashBackground,
    required this.readingBackground,
    required this.activeCardBackground,
    required this.activeCardBorder,
    required this.archivedCardBackground,
    required this.archivedCardBorder,
    required this.cardDateText,
    required this.archivedTitle,
    required this.archivedDate,
    required this.primaryText,
    required this.secondaryText,
    required this.hintText,
    required this.subtitleText,
    required this.dividerText,
    required this.divider,
    required this.gradientOverlay,
    required this.gradientAccentStart,
    required this.gradientAccentEnd,
    required this.scrim,
    required this.button,
    required this.selected,
    required this.border,
    required this.inputFill,
    required this.inputBorder,
    required this.formCard,
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
    required this.activeEventDot,
    required this.highlight,
    required this.bookmark,
    required this.google,
    required this.apple,
    required this.overlay,
    required this.shimmer,
    required this.photoSlot,
    required this.tipsBackground,
    required this.enrollDisabled,
    required this.shadowSoft,
    required this.shadowMedium,
    required this.tabUnselectedText,
    required this.tabDivider,
  });

  final Color primaryAccent;
  final Color secondaryAccent;
  final Color accent;

  final Color neutral0;
  final Color neutral100;
  final Color neutral200;
  final Color neutral300;
  final Color neutral400;
  final Color neutral500;
  final Color neutral600;
  final Color neutral700;
  final Color neutral800;
  final Color neutral850;
  final Color neutral900;
  final Color neutral950;

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color card;
  final Color onboardingBackground;
  final Color splashBackground;
  final Color readingBackground;
  final Color activeCardBackground;
  final Color activeCardBorder;
  final Color archivedCardBackground;
  final Color archivedCardBorder;
  final Color cardDateText;
  final Color archivedTitle;
  final Color archivedDate;

  final Color primaryText;
  final Color secondaryText;
  final Color hintText;
  final Color subtitleText;

  final Color dividerText;
  final Color divider;
  final Color gradientOverlay;
  final Color gradientAccentStart;
  final Color gradientAccentEnd;
  final Color scrim;

  final Color button;
  final Color selected;
  final Color border;
  final Color inputFill;
  final Color inputBorder;
  final Color formCard;

  final Color success;
  final Color error;
  final Color warning;
  final Color info;
  final Color activeEventDot;

  final Color highlight;
  final Color bookmark;
  final Color google;
  final Color apple;
  final Color overlay;
  final Color shimmer;
  final Color photoSlot;
  final Color tipsBackground;
  final Color enrollDisabled;

  final Color shadowSoft;
  final Color shadowMedium;
  final Color tabUnselectedText;
  final Color tabDivider;

  /// Dark-mode palette, derived from the original [AppThemeColors] tokens.
  static const AppPalette dark = AppPalette(
    primaryAccent: AppThemeColors.primaryAccent,
    secondaryAccent: AppThemeColors.secondaryAccent,
    accent: AppThemeColors.accent,
    neutral0: AppThemeColors.neutral0,
    neutral100: AppThemeColors.neutral100,
    neutral200: AppThemeColors.neutral200,
    neutral300: AppThemeColors.neutral300,
    neutral400: AppThemeColors.neutral400,
    neutral500: AppThemeColors.neutral500,
    neutral600: AppThemeColors.neutral600,
    neutral700: AppThemeColors.neutral700,
    neutral800: AppThemeColors.neutral800,
    neutral850: AppThemeColors.neutral850,
    neutral900: AppThemeColors.neutral900,
    neutral950: AppThemeColors.neutral950,
    background: AppThemeColors.background,
    surface: AppThemeColors.surface,
    surfaceHigh: AppThemeColors.surfaceHigh,
    card: AppThemeColors.card,
    onboardingBackground: AppThemeColors.onboardingBackground,
    splashBackground: AppThemeColors.splashBackground,
    readingBackground: AppThemeColors.readingBackground,
    activeCardBackground: AppThemeColors.activeCardBackground,
    activeCardBorder: AppThemeColors.activeCardBorder,
    archivedCardBackground: AppThemeColors.archivedCardBackground,
    archivedCardBorder: AppThemeColors.archivedCardBorder,
    cardDateText: AppThemeColors.cardDateText,
    archivedTitle: AppThemeColors.archivedTitle,
    archivedDate: AppThemeColors.archivedDate,
    primaryText: AppThemeColors.primaryText,
    secondaryText: AppThemeColors.secondaryText,
    hintText: AppThemeColors.hintText,
    subtitleText: AppThemeColors.subtitleText,
    dividerText: AppThemeColors.dividerText,
    divider: AppThemeColors.divider,
    gradientOverlay: AppThemeColors.gradientOverlay,
    gradientAccentStart: AppThemeColors.gradientAccentStart,
    gradientAccentEnd: AppThemeColors.gradientAccentEnd,
    scrim: AppThemeColors.scrim,
    button: AppThemeColors.button,
    selected: AppThemeColors.selected,
    border: AppThemeColors.border,
    inputFill: AppThemeColors.inputFill,
    inputBorder: AppThemeColors.inputBorder,
    formCard: AppThemeColors.formCard,
    success: AppThemeColors.success,
    error: AppThemeColors.error,
    warning: AppThemeColors.warning,
    info: AppThemeColors.info,
    activeEventDot: AppThemeColors.activeEventDot,
    highlight: AppThemeColors.highlight,
    bookmark: AppThemeColors.bookmark,
    google: AppThemeColors.google,
    apple: AppThemeColors.apple,
    overlay: AppThemeColors.overlay,
    shimmer: AppThemeColors.shimmer,
    photoSlot: AppThemeColors.photoSlot,
    tipsBackground: AppThemeColors.tipsBackground,
    enrollDisabled: AppThemeColors.enrollDisabled,
    shadowSoft: AppThemeColors.shadowSoft,
    shadowMedium: AppThemeColors.shadowMedium,
    tabUnselectedText: AppThemeColors.tabUnselectedText,
    tabDivider: AppThemeColors.tabDivider,
  );

  /// Light-mode palette, derived from [AppThemeColorsLight] with light
  /// equivalents for the tokens that only existed in the dark palette.
  static const AppPalette light = AppPalette(
    primaryAccent: AppThemeColorsLight.primaryAccent,
    secondaryAccent: AppThemeColorsLight.secondaryAccent,
    accent: AppThemeColorsLight.accent,
    neutral0: AppThemeColorsLight.neutral0,
    neutral100: AppThemeColorsLight.neutral100,
    neutral200: AppThemeColorsLight.neutral200,
    neutral300: AppThemeColorsLight.neutral300,
    neutral400: AppThemeColorsLight.neutral400,
    neutral500: AppThemeColorsLight.neutral500,
    neutral600: AppThemeColorsLight.neutral600,
    neutral700: AppThemeColorsLight.neutral700,
    neutral800: AppThemeColorsLight.neutral800,
    neutral850: AppThemeColorsLight.neutral850,
    neutral900: AppThemeColorsLight.neutral900,
    neutral950: AppThemeColorsLight.neutral950,
    background: AppThemeColorsLight.background,
    surface: AppThemeColorsLight.surface,
    surfaceHigh: AppThemeColorsLight.surfaceHigh,
    card: AppThemeColorsLight.card,
    onboardingBackground: AppThemeColorsLight.neutral900,
    splashBackground: AppThemeColorsLight.neutral950,
    readingBackground: AppThemeColorsLight.neutral900,
    activeCardBackground: AppThemeColorsLight.neutral950,
    activeCardBorder: AppThemeColorsLight.neutral600,
    archivedCardBackground: AppThemeColorsLight.neutral850,
    archivedCardBorder: AppThemeColorsLight.neutral700,
    cardDateText: AppThemeColorsLight.neutral300,
    archivedTitle: AppThemeColorsLight.neutral200,
    archivedDate: AppThemeColorsLight.neutral400,
    primaryText: AppThemeColorsLight.primaryText,
    secondaryText: AppThemeColorsLight.secondaryText,
    hintText: AppThemeColorsLight.hintText,
    subtitleText: AppThemeColorsLight.subtitleText,
    dividerText: AppThemeColorsLight.neutral300,
    divider: AppThemeColorsLight.divider,
    gradientOverlay: AppThemeColors.gradientOverlay,
    gradientAccentStart: AppThemeColors.gradientAccentStart,
    gradientAccentEnd: AppThemeColors.gradientAccentEnd,
    scrim: AppThemeColors.scrim,
    button: AppThemeColorsLight.button,
    selected: AppThemeColorsLight.selected,
    border: AppThemeColorsLight.border,
    inputFill: AppThemeColorsLight.inputFill,
    inputBorder: AppThemeColorsLight.inputBorder,
    formCard: AppThemeColors.formCard,
    success: AppThemeColorsLight.success,
    error: AppThemeColorsLight.error,
    warning: AppThemeColorsLight.warning,
    info: AppThemeColorsLight.info,
    activeEventDot: AppThemeColorsLight.success,
    highlight: AppThemeColorsLight.accent,
    bookmark: AppThemeColorsLight.primaryAccent,
    google: AppThemeColors.google,
    apple: Color(0xFF000000),
    overlay: AppThemeColors.overlay,
    shimmer: AppThemeColorsLight.neutral700,
    photoSlot: AppThemeColorsLight.neutral600,
    tipsBackground: Color(0x14000000),
    enrollDisabled: Color(0x33BDBDC8),
    shadowSoft: AppThemeColorsLight.shadowSoft,
    shadowMedium: AppThemeColorsLight.shadowMedium,
    tabUnselectedText: AppThemeColorsLight.tabUnselectedText,
    tabDivider: Color.fromRGBO(0, 0, 0, 0.08),
  );
}

/// Resolves the palette that matches the current theme brightness.
extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}
