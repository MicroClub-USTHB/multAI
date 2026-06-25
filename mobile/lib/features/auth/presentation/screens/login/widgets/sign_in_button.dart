import 'package:flutter/material.dart';
import '../../../../../../core/extensions/context_extensions.dart';

class SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.textTheme;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: cs.onPrimary, size: 18),
                ],
              ),
      ),
    );
  }
}
