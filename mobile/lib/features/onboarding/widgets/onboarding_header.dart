import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class OnboardingHeader extends StatelessWidget {
  final VoidCallback onSkip;
  const OnboardingHeader({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemeMetrics.spacingLg,
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onSkip,
          child: Text(
            'Skip',
            style: TextStyle(
              color: AppThemeColors.primaryAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
