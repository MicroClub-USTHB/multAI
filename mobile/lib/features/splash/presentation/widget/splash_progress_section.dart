import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class SplashProgressSection extends StatelessWidget {
  const SplashProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 5),
      curve: Curves.linear,
      builder: (context, value, child) {
        final percent = (value * 100).round().clamp(0, 100);

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INITIALIZING ENGINE',
                  style: TextStyle(
                    letterSpacing: 2.4,
                    fontSize: 16,
                    color: AppThemeColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppThemeColors.subtitleText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemeMetrics.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 2,
                backgroundColor: AppThemeColors.border.withValues(alpha: 0.35),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppThemeColors.gold,
                ),
              ),
            ),
            const SizedBox(height: AppThemeMetrics.spacingLg),
            child ?? const SizedBox.shrink(),
          ],
        );
      },
      child: const Row(
        children: [
          Expanded(child: _SplashCard(icon: Icons.photo_outlined)),
          SizedBox(width: 8),
          Expanded(child: _SplashCard(icon: Icons.videocam_outlined)),
          SizedBox(width: 8),
          Expanded(child: _SplashCard(icon: Icons.face_outlined)),
        ],
      ),
    );
  }
}

class _SplashCard extends StatelessWidget {
  final IconData icon;

  const _SplashCard({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Icon(
        icon,
        color: AppThemeColors.gold.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }
}
