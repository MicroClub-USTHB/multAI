import 'package:flutter/material.dart';
import 'package:multai_mobile/core/constants/images.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppImages.mcLogoWhite,
          width: 132,
          height: 72,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppThemeMetrics.spacingXl),
        RichText(
          text: TextSpan(
            style: context.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              color: AppThemeColors.primaryText,
            ),
            children: const [
              TextSpan(text: 'mult'),
              TextSpan(
                text: 'AI',
                style: TextStyle(color: AppThemeColors.primaryAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppThemeMetrics.spacingSm),
        Text(
          'Your moments, found automatically',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppThemeColors.subtitleText,
          ),
        ),
      ],
    );
  }
}
