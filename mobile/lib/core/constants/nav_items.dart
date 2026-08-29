import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../router/app_routes.dart';

enum NavItem { home, gallery, event, account }

class NavItemData {
  final NavItem item;
  final FaIconData icon;
  final String label;
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
    icon: FontAwesomeIcons.house,
    label: 'HOME',
    route: AppRoutes.events,
  ),
  NavItemData(
    item: NavItem.gallery,
    icon: FontAwesomeIcons.images,
    label: 'GALLERY',
    route: AppRoutes.gallery,
  ),
  NavItemData(
    item: NavItem.event,
    icon: FontAwesomeIcons.calendar,
    label: 'EVENT',
    route: AppRoutes.eventGrid,
  ),
  NavItemData(
    item: NavItem.account,
    icon: FontAwesomeIcons.user,
    label: 'ACCOUNT',
    route: AppRoutes.account,
  ),
];
