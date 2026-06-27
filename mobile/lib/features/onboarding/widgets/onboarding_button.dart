import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLast;

  const OnboardingButton({super.key, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppThemeColors.gold, width: 1.5),
          color: isLast ? AppThemeColors.gold : Colors.transparent,
        ),
        child: Icon(
          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
          color: isLast ? Colors.white : AppThemeColors.gold,
          size: 22,
        ),
      ),
    );
  }
}
