import 'images.dart';

class OnboardingSlide {
  final String image;
  final String title;
  final String highlight;
  final String description;

  const OnboardingSlide({
    required this.image,
    required this.title,
    required this.highlight,
    required this.description,
  });
}

const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    image: AppImages.onboardingHero,
    title: 'Discover Your',
    highlight: 'Moments',
    description:
        'MultiAi uses advanced matching to surface your event photos automatically.',
  ),
  OnboardingSlide(
    image: AppImages.mcLogoBackground,
    title: 'Powered by',
    highlight: 'Micro Club',
    description:
        'Your profile stays consistent across the app with a clean branded identity.',
  ),
];
