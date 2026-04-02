import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/di/injection_container.dart';
import 'package:multai_mobile/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_footer.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_logo.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_progress_section.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SplashBloc>()..add(const InitializeApp()),
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SplashLoaded) {
            context.go(state.route);
          }
        },
        child: Scaffold(
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
        ),
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
