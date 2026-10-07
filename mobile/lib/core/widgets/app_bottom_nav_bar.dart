import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/nav_items.dart';
import '../theme/app_theme_colors.dart';
import '../theme/app_theme_colors_light.dart';
import '../extensions/context_extensions.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';

class AppBottomNavBar extends StatelessWidget {
  final NotchBottomBarController controller;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  String _getNavLabel(BuildContext context, NavItem item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item) {
      case NavItem.home:
        return l10n.home;
      case NavItem.gallery:
        return l10n.gallery;
      case NavItem.event:
        return l10n.event;
      case NavItem.account:
        return l10n.account;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    final tabUnselectedColor = isDark
        ? AppThemeColors.tabUnselectedText
        : AppThemeColorsLight.tabUnselectedText;

    final tabSelectedColor = isDark
        ? AppThemeColors.primaryAccent
        : AppThemeColorsLight.primaryAccent;

    final barColor = context.theme.colorScheme.surface;

    return AnimatedNotchBottomBar(
      notchBottomBarController: controller,
      color: barColor,
      showLabel: false,
      notchColor: barColor,
      bottomBarItems: navItems
          .map(
            (data) => BottomBarItem(
              inActiveItem: FaIcon(
                data.icon,
                color: tabUnselectedColor,
                size: 20,
              ),
              activeItem: FaIcon(data.icon, color: tabSelectedColor, size: 20),
              itemLabel: _getNavLabel(context, data.label),
            ),
          )
          .toList(),
      onTap: onTap,
      kIconSize: 24.0,
      kBottomRadius: 16.0,
      durationInMilliSeconds: 300,
      elevation: 0.0,
      showTopRadius: false,
      showBottomRadius: false,
    );
  }
}
