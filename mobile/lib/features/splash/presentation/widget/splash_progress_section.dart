import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

/// A quiet, honest loading indicator for the splash. No fake percentages or
/// "initializing engine" theatre, just a slim indeterminate bar.
class SplashProgressSection extends StatelessWidget {
  const SplashProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 3,
          backgroundColor: context.colors.surfaceHigh,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.colors.primaryAccent,
          ),
        ),
      ),
    );
  }
}
