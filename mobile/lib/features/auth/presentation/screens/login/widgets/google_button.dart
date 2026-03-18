import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/constants/images.dart';

class GoogleButton extends StatelessWidget {
  final bool isLoading;
  const GoogleButton({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.primaryTextColor,
          foregroundColor: Colors.black87,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppImages.googleLogo, height: 18, width: 18),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              'Google',
              style: tt.titleMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
