import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../onboarding/domain/usecases/get_onboarding_seen.dart';
import '../../domain/is_user_loged_in.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetOnboardingSeen getOnboardingSeen;
  final IsUserLoggedIn isUserLoggedIn;

  SplashBloc({required this.getOnboardingSeen, required this.isUserLoggedIn})
    : super(const SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      await Future.delayed(const Duration(seconds: 5));

      final hasSeenOnboarding = await getOnboardingSeen();
      if (!hasSeenOnboarding) {
        emit(const SplashLoaded(route: '/onboarding'));
        return;
      }
      final loggedInResult = await isUserLoggedIn(NoParams());

      loggedInResult.fold(
        (failure) => emit(const SplashLoaded(route: '/login')),
        (isLoggedIn) {
          if (isLoggedIn) {
            emit(const SplashLoaded(route: '/home'));
          } else {
            emit(const SplashLoaded(route: '/login'));
          }
        },
      );
    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }
}
