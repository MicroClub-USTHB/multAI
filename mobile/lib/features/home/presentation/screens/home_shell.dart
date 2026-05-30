import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../../../../core/widgets/app_bottom_nav_bar.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // get current route to highlight correct tab
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: child,
      bottomNavigationBar: AppBottomNavBar(currentRoute: currentRoute),
    );
  }
}
