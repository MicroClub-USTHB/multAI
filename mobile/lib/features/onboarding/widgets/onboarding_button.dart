import 'package:flutter/material.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLast;

  const OnboardingButton({super.key, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: context.widthCalculated(60),
        height: context.widthCalculated(60),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.primaryAccent, width: 1.5),
          color: isLast ? context.colors.primaryAccent : Colors.transparent,
        ),
        child: Icon(
          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
          color: isLast ? Colors.white : context.colors.primaryAccent,
          size: context.iconSize(),
        ),
      ),
    );
  }
}
