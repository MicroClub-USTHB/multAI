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

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController.reset();
    _animController.forward();
  }

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
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: slides
                        .map(
                          (slide) => AnimatedBuilder(
                            animation: _animController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _cardFade,
                                child: SlideTransition(
                                  position: _cardSlide,
                                  child: child,
                                ),
                              );
                            },
                            child: OnboardingCard(
                              image: slide.image,
                              title: slide.title,
                              highlight: slide.highlight,
                              description: slide.description,
                            ),
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
                      FadeTransition(
                        opacity: _textFade,
                        child: Builder(
                          builder: (buttonContext) {
                            return OnboardingButton(
                              onTap: () async {
                                if (_currentPage < slides.length - 1) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
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
