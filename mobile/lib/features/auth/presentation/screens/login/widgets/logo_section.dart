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
          padding: EdgeInsets.all(context.widthCalculated(4)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: Image.asset(AppImages.mcLogoWhite, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: context.heightCalculated(16)),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontSize: context.titleFontSize(),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.heightCalculated(6)),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
