import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  final String title;
  final String highlight;
  final String description;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.5,
                        colors: [
                          AppTheme.gold.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Image.asset(image, fit: BoxFit.cover, width: double.infinity),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Flexible(
          flex: 2,
          child: Column(
            children: [
              Text(
                title,
                style: AppTheme.onbaordingLargeText.copyWith(height: 1),
              ),
              Text(
                highlight,
                style: AppTheme.onbaordingLargeText.copyWith(
                  color: AppTheme.gold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTheme.onbaordingMediumText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
