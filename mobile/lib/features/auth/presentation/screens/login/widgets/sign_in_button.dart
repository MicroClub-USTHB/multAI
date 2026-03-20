import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
 
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
      height: context.heightCalculated(52),
      width: double.infinity,
      child: ElevatedButton(
        // ElevatedButtonTheme from AppTheme handles color + shape
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: context.heightCalculated(20),
                width: context.heightCalculated(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: cs.onPrimary,
                ),
              )
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
                  SizedBox(width: context.widthCalculated(6)),
                  Icon(
                    Icons.arrow_forward,
                    color: cs.onPrimary,
                    size: context.iconSize(),
                  ),
                ],
              ),
      ),
    );
  }
}
 