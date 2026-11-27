import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/nav_items.dart';
import '../extensions/context_extensions.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabUnselectedColor = context.colors.tabUnselectedText;
    final tabSelectedColor = context.colors.primaryAccent;

    final barColor = context.theme.colorScheme.surface;
    final backgroundColor = context.theme.scaffoldBackgroundColor;

    return CurvedNavigationBar(
      index: currentIndex,
      color: barColor,
      buttonBackgroundColor: tabSelectedColor,
      backgroundColor: backgroundColor,
      height: 64.0,
      animationCurve: Curves.easeOutCubic,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onTap,
      items: List<Widget>.generate(navItems.length, (index) {
        final isSelected = index == currentIndex;
        return FaIcon(
          navItems[index].icon,
          size: 22,
          color: isSelected ? Colors.white : tabUnselectedColor,
        );
      }),
    );
  }
}
