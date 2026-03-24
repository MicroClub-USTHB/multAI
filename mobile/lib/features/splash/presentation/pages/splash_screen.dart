import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' show Widget, BuildContext;
import 'package:http/retry.dart';
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              _buildLogo(context),
              const Spacer(flex: 1),
              _buildProgressSection(context),
              const Spacer(flex: 3),
              // const SizedBox(height: AppTheme.spacingLg),
              _buildFooter(context),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Image.asset(
          'assets/images/MC_white.png',
          width: 145,
          height: 80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.04),

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
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Your moments, found automatically',
          style: AppTheme.splashMediumText,
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INITIALIZING ENGINE',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 2.4,
                fontSize: 16,
                color: AppTheme.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '42%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                color: AppTheme.slateGray,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppTheme.spacingSm),

        const LinearProgressIndicator(value: 0.42, minHeight: 2),

        const SizedBox(height: AppTheme.spacingLg),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildCard(Icons.photo_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildCard(Icons.videocam_outlined)),
            const SizedBox(width: 8),
            Expanded(child: _buildCard(Icons.face_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(IconData icon) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Icon(icon, color: AppTheme.gold.withOpacity(0.4), size: 24),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppTheme.appleColor,
            thickness: 1,
            indent: 24,
            endIndent: 16,
          ),
        ),

        Text(
          'SECURE NEURAL PROCESSING',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 2.4,
            fontSize: 12,
            color: AppTheme.slateGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppTheme.borderColor,
            thickness: 1,
            indent: 16,
            endIndent: 24,
          ),
        ),
      ],
    );
  }
}
