import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class SplashFooter extends StatelessWidget {
  const SplashFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppThemeColors.divider,
            thickness: 1,
            indent: 28,
            endIndent: 8,
          ),
        ),
        Text(
          'SECURE NEURAL PROCESSING',
          style: TextStyle(
            letterSpacing: 3,
            fontSize: 10,
            color: AppThemeColors.dividerText,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppThemeColors.divider,
            thickness: 1,
            indent: 8,
            endIndent: 28,
          ),
        ),
      ],
    );
  }
}
