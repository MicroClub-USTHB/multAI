import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../constants/nav_items.dart';
import '../theme/theme.dart';
 
class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;
 
  const AppBottomNavBar({
    super.key,
    required this.currentRoute,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.inputBorderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems
            .map(
              (data) => _NavBarItem(
                icon:       data.icon,
                label:      data.label,
                isSelected: currentRoute == data.route,
                onTap:      () => context.go(data.route),
              ),
            )
            .toList(),
      ),
    );
  }
}
 
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
 
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppTheme.primaryColor
        : AppTheme.secondaryTextColor;
 
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:       color,
                fontSize:    10,
                fontWeight:  FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 