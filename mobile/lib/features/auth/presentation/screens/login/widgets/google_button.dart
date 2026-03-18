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
      width: double.infinity, // Ensure it fills the container width
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
          mainAxisAlignment: MainAxisAlignment.center, // Fixes horizontal positioning
          children: [
            Image.asset(
              AppImages.googleLogo,
              height: 18,
              width: 18,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.g_mobiledata,
                color: Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
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
