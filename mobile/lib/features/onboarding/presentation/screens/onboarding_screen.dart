import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/theme/theme.dart';
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
          backgroundColor: AppTheme.onboardingBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                OnboardingHeader(onSkip: () => _pageController.jumpToPage(2)),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    children: const [
                      OnboardingCard(
                        image: 'assets/images/onboarding.png',
                        title: 'Discover Your',
                        highlight: 'Moments',
                        description:
                            "MultiAi uses advanced neural processing to find you in any event photo automatically",
                      ),
                      // test navigation
                      OnboardingCard(
                        image: 'assets/images/MC_white.png',
                        title: 'page',
                        highlight: '2',
                        description:
                            'MultiAi uses advanced neural processing...',
                      ),
                      // for test
                      OnboardingCard(
                        image: 'assets/images/MC_black.png',
                        title: 'page',
                        highlight: '3',
                        description:
                            'MultiAi uses advanced neural processing...',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    children: [
                      OnboardingIndicator(
                        currentPage: _currentPage,
                        itemCount: 3,
                      ),
                      const SizedBox(height: 32),
                      Builder(
                        builder: (buttonContext) {
                          return OnboardingButton(
                            onTap: () async {
                              if (_currentPage < 2) {
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
