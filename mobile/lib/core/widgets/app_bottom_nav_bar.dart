import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/nav_items.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppThemeColors.background,
        border: Border(
          top: BorderSide(color: AppThemeColors.inputBorder, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((data) {
          final isSelected = currentRoute.startsWith(data.route);

          // ── notifications tab needs unread badge ────────────────────
          if (data.item == NavItem.notifications) {
            return BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final unread = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;
                return _NavBarItem(
                  icon: data.icon,
                  label: data.label,
                  isSelected: isSelected,
                  badgeCount: unread,
                  onTap: () => context.go(data.route),
                );
              },
            );
          }

          return _NavBarItem(
            icon: data.icon,
            label: data.label,
            isSelected: isSelected,
            onTap: () => context.go(data.route),
          );
        }).toList(),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppThemeColors.primaryAccent
        : AppThemeColors.secondaryText;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppThemeColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
