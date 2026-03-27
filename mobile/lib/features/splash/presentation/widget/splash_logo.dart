import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
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
}
