import 'package:flutter/material.dart';
import 'package:multai_mobile/core/constants/images.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_text_styles.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Image.asset(
          AppImages.mcLogoWhite,
          width: 145,
          height: 80,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.04),
        RichText(
          text: TextSpan(
            style: AppThemeTextStyles.splashLargeText,
            children: [
              const TextSpan(text: 'Multi'),
              TextSpan(
                text: 'AI',
                style: TextStyle(color: AppThemeColors.gold),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          'Your moments, found automatically',
          style: AppThemeTextStyles.splashMediumText,
        ),
      ],
    );
  }
}
