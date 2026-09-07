import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../router/app_routes.dart';

enum NavItem { home, gallery, event, account }

class NavItemData {
  final NavItem item;
  final FaIconData icon;
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
    icon: FontAwesomeIcons.house,
    label: NavItem.home,
    route: AppRoutes.events,
  ),
  NavItemData(
    item: NavItem.gallery,
    icon: FontAwesomeIcons.images,
    label: NavItem.gallery,
    route: AppRoutes.gallery,
  ),
  NavItemData(
    item: NavItem.event,
    icon: FontAwesomeIcons.calendar,
    label: NavItem.event,
    route: AppRoutes.eventGrid,
  ),
  NavItemData(
    item: NavItem.account,
    icon: FontAwesomeIcons.user,
    label: NavItem.account,
    route: AppRoutes.account,
  ),
];
