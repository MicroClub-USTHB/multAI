import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/nav_items.dart';
import '../theme/app_theme_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final NotchBottomBarController controller;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNotchBottomBar(
      notchBottomBarController: controller,
      color: AppThemeColors.background,
      showLabel: false,
      notchColor: AppThemeColors.background,
      bottomBarItems: navItems
          .map(
            (data) => BottomBarItem(
              inActiveItem: FaIcon(
                data.icon,
                color: AppThemeColors.tabUnselectedText,
                size: 20,
              ),
              activeItem: FaIcon(
                data.icon,
                color: AppThemeColors.primaryAccent,
                size: 20,
              ),
              itemLabel: data.label,
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
