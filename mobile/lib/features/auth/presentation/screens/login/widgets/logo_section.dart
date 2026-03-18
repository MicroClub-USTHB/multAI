import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/constants/images.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Center(
            child: Image.asset(
              AppImages.mcLogoWhite,
              width: 50,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodySmall?.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}
