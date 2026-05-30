import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/constants/onboarding_content.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import 'package:multai_mobile/core/theme/app_theme_metrics.dart';
import 'package:multai_mobile/di/injection_container.dart';
import 'package:multai_mobile/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_button.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_card.dart';
import 'package:multai_mobile/features/onboarding/widgets/onboarding_header.dart';
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
  Widget build(BuildContext context) {
    final slides = onboardingSlides;
    return BlocProvider(
      create: (context) => sl<OnboardingBloc>(),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is OnboardingComplete) {
            context.go(state.route);
          }
        },

        child: Scaffold(
          backgroundColor: AppThemeColors.onboardingBackground,
          body: SafeArea(
            child: Column(
              children: [
                OnboardingHeader(
                  onSkip: () => _pageController.animateToPage(
                    slides.length - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: slides
                        .map(
                          (slide) => OnboardingCard(
                            image: slide.image,
                            title: slide.title,
                            highlight: slide.highlight,
                            description: slide.description,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppThemeMetrics.spacingLg),
                  child: Column(
                    children: [
                      OnboardingIndicator(
                        currentPage: _currentPage,
                        itemCount: slides.length,
                      ),
                      const SizedBox(height: 32),
                      Builder(
                        builder: (buttonContext) {
                          return OnboardingButton(
                            onTap: () async {
                              if (_currentPage < slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              } else {
                                buttonContext.read<OnboardingBloc>().add(
                                  CompleteOnboarding(),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
