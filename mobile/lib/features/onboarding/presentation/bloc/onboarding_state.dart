part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingRequired extends OnboardingState {}

class OnboardingComplete extends OnboardingState {
  final String route;

  const OnboardingComplete({required this.route});

  @override
  List<Object> get props => [route];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object> get props => [message];

}
