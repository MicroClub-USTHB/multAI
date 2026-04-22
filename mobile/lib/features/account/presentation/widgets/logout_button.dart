import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LogoutButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return SizedBox(
      width: double.infinity,
      height: context.heightCalculated(52),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppThemeColors.error.withValues(alpha: 0.1),
          side: BorderSide(color: AppThemeColors.error.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppThemeColors.error,
              size: context.iconSize(),
            ),
            SizedBox(width: context.widthCalculated(8)),
            Text(
              'Sign Out',
              style: tt.titleMedium?.copyWith(
                color: AppThemeColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
