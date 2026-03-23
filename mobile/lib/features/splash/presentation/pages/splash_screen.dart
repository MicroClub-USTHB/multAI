import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show Widget, BuildContext;
import 'package:multai_mobile/core/theme/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(context),
              const Spacer(flex: 3),
              // _buildProgressSection(),
              const SizedBox(height: AppTheme.spacingLg),
              // _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(
          'assets/images/MC_white.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppTheme.spacingMd),

        RichText(
          text: TextSpan(
            style: AppTheme.splashLargeText,
            children: [
              const TextSpan(text: 'Multi'),
              TextSpan(
                text: 'AI',
                style: TextStyle(color: AppTheme.gold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Your moments, found automatically',
          style: AppTheme.splashMediumText,
        ),
      ],
    );
  }
}
