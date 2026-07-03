import 'dart:math';

import 'images.dart';

class OnboardingItem {
  final String image;
  final String? secondImage;
  final String title;
  final String description;

  const OnboardingItem({
    required this.image,
    this.secondImage,
    required this.title,
    required this.description,
  });

  /// Creates a list of [OnboardingItem]s from randomly selected onboarding images.
  ///
  /// Each item carries fixed title/description text paired with a dynamic image.
  /// The middle slide optionally receives a [secondImage] when enough images exist.
  static List<OnboardingItem> createSlides({int count = 4}) {
    final pool = AppImages.onboardingImages;
    if (pool.isEmpty) return [];

    final random = Random();
    final shuffled = List<String>.of(pool)..shuffle(random);
    final images = shuffled.take(count.clamp(0, shuffled.length)).toList();

    final safe = images.length >= 3
        ? images
        : [...images, ...images, ...images].take(3).toList();

    return [
      OnboardingItem(
        image: safe[0],
        title: 'Your events,\ncaptured.',
        description:
            'Join Micro Club events — our team captures every moment for you.',
      ),
      OnboardingItem(
        image: safe[1],
        secondImage: safe.length > 3 ? safe[3] : null,
        title: 'Found\nautomatically.',
        description:
            'Our AI finds your face across every photo from every event.',
      ),
      OnboardingItem(
        image: safe[2],
        title: 'Keep your\nmoments.',
        description:
            'View, approve and download your photos whenever you want.',
      ),
    ];
  }
}
