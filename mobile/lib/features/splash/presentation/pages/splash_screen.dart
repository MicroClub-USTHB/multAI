import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/core/usecase/usecase.dart';
import 'package:multai_mobile/di/injection_container.dart';
import 'package:multai_mobile/features/onboarding/domain/usecases/get_onboarding_seen.dart';
import 'package:multai_mobile/features/splash/domain/is_user_loged_in.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_footer.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_logo.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_progress_section.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final getOnboardingSeen = sl<GetOnboardingSeen>();
    final hasSeenOnboarding = await getOnboardingSeen();
    if (!mounted) return;
    if (!hasSeenOnboarding) {
      context.go('/onboarding');
      return;
    }

    final isUserLoggedIn = sl<IsUserLoggedIn>();
    final result = await isUserLoggedIn(NoParams());

    result.fold((failure) => context.go(AppRoutes.login), (isLoggedIn) {
      if (isLoggedIn) {
        context.go('/home/events');
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splashBackgroundColor,
      body: Stack(
        children: [
          _buildGlow(Alignment.topLeft),
          _buildGlow(Alignment.bottomRight),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  Spacer(flex: 3),
                  SplashLogo(),
                  Spacer(flex: 1),
                  SplashProgressSection(),
                  Spacer(flex: 3),
                  SplashFooter(),
                  SizedBox(height: AppTheme.spacingLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Alignment alignment) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: 0.5,
            colors: [AppTheme.gold.withValues(alpha: 0.15), Colors.transparent],
          ),
        ),
      ),
    );
  }
}
