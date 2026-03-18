import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? CircularProgressIndicator(color: cs.onPrimary)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: tt.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: cs.onPrimary),
                ],
              ),
      ),
    );
  }
}