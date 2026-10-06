import 'package:flutter/material.dart';
import 'package:multai_mobile/core/constants/onboarding_content.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingItem slide;
  final int slideIndex;

  const OnboardingCard({
    super.key,
    required this.slide,
    required this.slideIndex,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final compositionHeight = screenHeight * 0.54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: compositionHeight,
          child: _buildComposition(context, compositionHeight),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.hPadding(),
              context.heightCalculated(28),
              context.hPadding(),
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppThemeColors.primaryAccent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  slide.title,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: AppThemeColors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppThemeColors.secondaryText,
                    height: 1.55,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Reserve space for bottom nav overlay
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildComposition(BuildContext context, double height) {
    switch (slideIndex % 3) {
      case 0:
        return _buildSlide0(context, height);
      case 1:
        return _buildSlide1(context, height);
      case 2:
        return _buildSlide2(context, height);
      default:
        return _buildSlide0(context, height);
    }
  }

  // Slide 0: large rounded-rect photo left + big accent circle overlapping right
  Widget _buildSlide0(BuildContext context, double height) {
    final circleSize = height * 0.76;
    final photoW = height * 0.60;
    final photoH = height * 0.70;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Big accent circle — right, partially off-screen
        Positioned(
          top: -(height * 0.14),
          right: -(height * 0.08),
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              color: AppThemeColors.primaryAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main photo — rounded rect, overlaps the accent circle
        Positioned(
          top: height * 0.06,
          left: context.hPadding(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              slide.image,
              width: photoW,
              height: photoH,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
        ),
        // Small accent dot — bottom right of composition area
        Positioned(
          bottom: height * 0.06,
          right: context.widthCalculated(56),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppThemeColors.primaryAccent.withValues(alpha: 0.28),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  // Slide 1: two overlapping circular photos
  Widget _buildSlide1(BuildContext context, double height) {
    final largeSize = height * 0.52;
    final smallSize = height * 0.34;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Faint accent circle — background, top-left
        Positioned(
          top: -(height * 0.1),
          left: -context.widthCalculated(36),
          child: Container(
            width: height * 0.66,
            height: height * 0.66,
            decoration: BoxDecoration(
              color: AppThemeColors.primaryAccent.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Large circle photo — center-left
        Positioned(
          top: height * 0.10,
          left: context.hPadding(),
          child: _photoCircle(slide.image, largeSize),
        ),
        // Smaller circle photo — right side, higher up
        if (slide.secondImage != null)
          Positioned(
            top: 0,
            right: context.widthCalculated(28),
            child: _photoCircle(slide.secondImage!, smallSize),
          ),
        // Small dark dot — floating accent
        Positioned(
          bottom: height * 0.10,
          right: height * 0.27,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: AppThemeColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppThemeColors.primaryAccent.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Slide 2: centered large circle photo + accent
  Widget _buildSlide2(BuildContext context, double height) {
    final circleSize = height * 0.60;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Faint accent circle — top-right, partially off-screen
        Positioned(
          top: -(height * 0.18),
          right: -(height * 0.10),
          child: Container(
            width: height * 0.70,
            height: height * 0.70,
            decoration: BoxDecoration(
              color: AppThemeColors.primaryAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Main large circle photo — centered
        Positioned(
          top: height * 0.07,
          left: 0,
          right: 0,
          child: Center(child: _photoCircle(slide.image, circleSize)),
        ),
        // Small accent dot — bottom-left
        Positioned(
          bottom: height * 0.08,
          left: context.widthCalculated(44),
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppThemeColors.primaryAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoCircle(String imagePath, double size) {
    return ClipOval(
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      ),
    );
  }
}
