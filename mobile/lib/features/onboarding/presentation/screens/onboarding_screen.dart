import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/constants/onboarding_content.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/di/injection_container.dart';
import 'package:multai_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_button.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_card.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_indicatore.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext ctx) {
    if (_currentPage < onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      ctx.read<OnboardingBloc>().add(CompleteOnboarding());
    }
  }

  @override
  Widget build(BuildContext context) {
    final slides = onboardingSlides;
    final isLast = _currentPage == slides.length - 1;

    return BlocProvider(
      create: (_) => sl<OnboardingBloc>(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingComplete) context.go(state.route);
        },
        child: Scaffold(
          backgroundColor: AppThemeColors.background,
          body: Builder(
            builder: (ctx) {
              return Stack(
                children: [
                  // Full-screen PageView
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: slides.length,
                    itemBuilder: (_, i) => OnboardingCard(
                      slide: slides[i],
                      slideIndex: i,
                    ),
                  ),

                  // Skip button — top right
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        child: AnimatedOpacity(
                          opacity: isLast ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTap: () => ctx
                                .read<OnboardingBloc>()
                                .add(CompleteOnboarding()),
                            child: Text(
                              'Skip',
                              style: context.textTheme.labelLarge?.copyWith(
                                color: AppThemeColors.gold,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom navigation — indicators left, arrow right
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OnboardingIndicator(
                              currentPage: _currentPage,
                              itemCount: slides.length,
                            ),
                            OnboardingButton(
                              isLast: isLast,
                              onTap: () => _nextPage(ctx),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
