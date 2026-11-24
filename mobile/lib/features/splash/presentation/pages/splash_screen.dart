import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/di/injection_container.dart';
import 'package:multai_mobile/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_footer.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_logo.dart';
import 'package:multai_mobile/features/splash/presentation/widget/splash_progress_section.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _progressFade;
  late Animation<Offset> _progressSlide;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _progressFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );
    _progressSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );
    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SplashBloc>()..add(const InitializeApp()),
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashError) {
            context.showErrorSnackBar(state.message);
          } else if (state is SplashLoaded) {
            context.go(state.route);
          }
        },
        builder: (context, state) {
          if (state is SplashOffline) {
            return _buildOfflineScreen(context);
          }
          if (state is SplashSecurityWarning) {
            return _buildSecurityWarningScreen(context, state);
          }
          return Scaffold(
            backgroundColor: context.colors.splashBackground,
            body: Stack(
              children: [
                _buildGlow(Alignment.topLeft),
                _buildGlow(Alignment.bottomRight),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppThemeMetrics.spacingLg),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: const SplashLogo(),
                          ),
                        ),
                        const Spacer(flex: 2),
                        FadeTransition(
                          opacity: _progressFade,
                          child: SlideTransition(
                            position: _progressSlide,
                            child: const SplashProgressSection(),
                          ),
                        ),
                        const Spacer(flex: 3),
                        FadeTransition(
                          opacity: _footerFade,
                          child: const SplashFooter(),
                        ),
                        const SizedBox(height: AppThemeMetrics.spacingLg),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecurityWarningScreen(
    BuildContext context,
    SplashSecurityWarning state,
  ) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.splashBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeMetrics.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SplashLogo(),
              const SizedBox(height: AppThemeMetrics.spacingXl),
              Icon(
                Icons.security_rounded,
                size: context.iconSize() * 3,
                color: context.colors.error.withValues(alpha: 0.8),
              ),
              const SizedBox(height: AppThemeMetrics.spacingLg),
              Text(
                l10n.securityAlert,
                style: tt.headlineSmall?.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              const SizedBox(height: AppThemeMetrics.spacingSm),
              Text(
                state.message,
                style: tt.bodySmall?.copyWith(
                  color: context.colors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineScreen(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.splashBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeMetrics.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SplashLogo(),
              const SizedBox(height: AppThemeMetrics.spacingXl),
              Icon(
                Icons.wifi_off_rounded,
                size: context.iconSize() * 3,
                color: context.colors.primaryAccent.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppThemeMetrics.spacingLg),
              Text(
                l10n.noInternetConnection,
                style: tt.headlineSmall?.copyWith(
                  color: context.colors.primaryText,
                ),
              ),
              const SizedBox(height: AppThemeMetrics.spacingSm),
              Text(
                l10n.checkConnectionAndRetry,
                style: tt.bodySmall?.copyWith(
                  color: context.colors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeMetrics.spacingXl),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<SplashBloc>().add(const RetryConnection()),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colors.primaryText,
                  backgroundColor: context.colors.primaryAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeMetrics.spacingXl,
                    vertical: AppThemeMetrics.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeMetrics.radiusSm,
                    ),
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
            radius: 0.6,
            colors: [
              context.colors.primaryAccent.withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
