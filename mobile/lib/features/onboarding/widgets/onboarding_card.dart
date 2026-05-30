import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_text_styles.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  final String? title;
  final String? highlight;
  final String description;

  const OnboardingCard({
    super.key,
    required this.image,
    this.title,
    this.highlight,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.52)
            .clamp(180.0, 280.0)
            .toDouble();

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeMetrics.spacingLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.5,
                                colors: [
                                  AppThemeColors.gold.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title ?? '',
                    style: AppThemeTextStyles.onboardingLargeText.copyWith(
                      height: 1,
                    ),
                  ),
                  Text(
                    highlight ?? '',
                    style: AppThemeTextStyles.onboardingLargeText.copyWith(
                      color: AppThemeColors.gold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: AppThemeTextStyles.onboardingMediumText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
