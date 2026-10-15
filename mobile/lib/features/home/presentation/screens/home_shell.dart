import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:multai_mobile/core/constants/nav_items.dart';
import '../../../../../core/widgets/app_bottom_nav_bar.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _currentNavIndex(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < navItems.length; i++) {
      if (currentRoute.startsWith(navItems[i].route)) return i;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
