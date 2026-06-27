import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class SplashFooter extends StatelessWidget {
  const SplashFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'by Micro Club',
      textAlign: TextAlign.center,
      style: context.textTheme.labelMedium?.copyWith(
        color: AppThemeColors.hintText,
        letterSpacing: 1.5,
      ),
    );
  }
}
