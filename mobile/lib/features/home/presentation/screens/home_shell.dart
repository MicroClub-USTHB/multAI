import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:multai_mobile/core/constants/nav_items.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../../../../core/widgets/app_bottom_nav_bar.dart';

class HomeShell extends StatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newIndex = _currentNavIndex(context);
    if (_controller.index != newIndex) {
      _controller.jumpTo(newIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _currentNavIndex(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < navItems.length; i++) {
      if (currentRoute.startsWith(navItems[i].route)) return i;
    }
    return 0;
  }

  void _onItemTapped(int index) {
    context.go(navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: widget.child,
      bottomNavigationBar: AppBottomNavBar(
        controller: _controller,
        onTap: _onItemTapped,
      ),
    );
  }
}
