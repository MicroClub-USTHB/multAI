import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    return GestureDetector(
      onTap: () {},
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
