class AppImages {
  static const String assetsPath = 'assets';
  static const String imagesPath = '$assetsPath/images';
  static const String iconsPath = '$assetsPath/icons';
  static const String onboardingPath = '$imagesPath/onboarding';

  // Existing images
  static const String mcLogoWhite = '$imagesPath/MC_white.png';

  // Brand logos
  static const String logoDark = '$imagesPath/logo_dark.png';
  static const String logoLight = '$imagesPath/logo_light.png';
  static const String logoMark = '$imagesPath/logo_mark.png';

  /// Pool of all available onboarding images.
  /// Add new entries here when you drop images into [onboardingPath].
  static const List<String> onboardingImages = [
    '$onboardingPath/1.webp',
    '$onboardingPath/2.webp',
    '$onboardingPath/3.webp',
    '$onboardingPath/4.webp',
    '$onboardingPath/5.webp',
    '$onboardingPath/6.webp',
    '$onboardingPath/7.webp',
    '$onboardingPath/8.webp',
    '$onboardingPath/9.webp',
    '$onboardingPath/10.webp',
    '$onboardingPath/11.webp',
    '$onboardingPath/12.webp',
    '$onboardingPath/13.webp',
  ];
}
