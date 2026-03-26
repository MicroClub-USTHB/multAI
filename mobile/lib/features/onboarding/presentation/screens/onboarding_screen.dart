import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.onboardingBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg,
                ),
                child: TextButton(
                  onPressed: () {
                    // TODO Navigate to login or home
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: 3,

                itemBuilder: (context, index) {
                  return _buildPageContent();
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  _buildPageIndicator(),
                  const SizedBox(height: 32),
                  _buildNextButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/onboarding.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        Flexible(flex: 2, child: _buildTextContent()),
      ],
    );
  }

  Widget _buildTextContent() {
    return Column(
      children: [
        Text(
          'Discover Your',
          style: AppTheme.onbaordingLargeText.copyWith(height: 1),
        ),
        Text(
          'Moments',
          style: AppTheme.onbaordingLargeText.copyWith(
            color: AppTheme.gold,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'MultiAi uses advanced neural processing to find you in any event photo automatically.',
            textAlign: TextAlign.center,
            style: AppTheme.onbaordingMediumText,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,

          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.gold
                : AppTheme.slateGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.gold,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
