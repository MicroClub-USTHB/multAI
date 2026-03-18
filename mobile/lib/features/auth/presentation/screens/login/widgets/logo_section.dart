import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
import '../../../../../../core/constants/images.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final logoSize = context.logoSize();

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          // Removed extra padding to match original "MC" logo fit
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(
              AppImages.mcLogoWhite,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontSize: context.titleFontSize(),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
