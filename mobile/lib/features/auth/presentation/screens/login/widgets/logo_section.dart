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

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE8A33A), // The exact orange from your screenshot
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Image.asset(
              AppImages.mcLogoWhite,
              width: 50,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'MultiAi',
          style: tt.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elevate your intelligence workspace',
          style: tt.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
