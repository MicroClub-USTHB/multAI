import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;

  const OnboardingButton({super.key, required this.onTap, this.text = 'Next'});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(12),
          ),

          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
