import 'package:flutter/material.dart';
import '../router/app_routes.dart';

enum NavItem { home, gallery, event, account }

class NavItemData {
  final NavItem item;
  final IconData icon;
  final NavItem label;
  final String route;

  const NavItemData({
    required this.item,
    required this.icon,
    required this.label,
    required this.route,
  });
}

const List<NavItemData> navItems = [
  NavItemData(
    item: NavItem.home,
    icon: Icons.home_outlined,
    label: NavItem.home,
    route: AppRoutes.events,
  ),
  NavItemData(
    item: NavItem.gallery,
    icon: Icons.image_outlined,
    label: NavItem.gallery,
    route: AppRoutes.gallery,
  ),
  NavItemData(
    item: NavItem.event,
    icon: Icons.calendar_month_outlined,
    label: NavItem.event,
    route: AppRoutes.eventGrid,
  ),
  NavItemData(
    item: NavItem.account,
    icon: Icons.person_outline,
    label: NavItem.account,
    route: AppRoutes.account,
  ),
];
