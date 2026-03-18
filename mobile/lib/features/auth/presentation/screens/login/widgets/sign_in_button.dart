import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';

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

    // Responsive sizing
    final buttonHeight = context.heightCalculated(52);
    final iconSize = context.widthCalculated(18);
    final spacing = context.widthCalculated(6);
    final textStyle = tt.titleLarge?.copyWith(
      color: cs.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: context.widthCalculated(16), // responsive text
    );

    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
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
                  Text('Sign In', style: textStyle),
                  SizedBox(width: spacing),
                  Icon(Icons.arrow_forward, color: cs.onPrimary, size: iconSize),
                ],
              ),
      ),
    );
  }
}