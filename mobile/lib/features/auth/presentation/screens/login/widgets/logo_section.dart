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

    // Use responsive sizing
    final logoSize = context.logoSize();
    final verticalSpacing = context.heightCalculated(16);
    final titleSpacing = context.heightCalculated(8);

    return Column(
      children: [
        // Logo container
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          padding: EdgeInsets.all(context.widthCalculated(4)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(
              AppImages.mcLogoWhite,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Space below logo
        SizedBox(height: verticalSpacing),

        // App title
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontSize: context.titleFontSize(),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        // Space below title
        SizedBox(height: titleSpacing),

        // Subtitle
        Text(
          'Elevate your intelligence workspace',
          style: tt.titleSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
            fontSize: context.widthCalculated(14), // scale subtitle
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}