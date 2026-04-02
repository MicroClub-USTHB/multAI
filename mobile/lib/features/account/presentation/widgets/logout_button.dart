import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';

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
          backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
          side: BorderSide(
            color: AppTheme.errorColor.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppTheme.errorColor,
              size: context.iconSize(),
            ),
            SizedBox(width: context.widthCalculated(8)),
            Text(
              'Sign Out',
              style: tt.titleMedium?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}