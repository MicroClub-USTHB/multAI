import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';

class ForgotPassword extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPassword({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Text(
        'Forgot?',
        style: tt.labelMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
