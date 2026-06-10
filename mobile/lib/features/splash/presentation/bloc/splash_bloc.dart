import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/router/app_routes.dart';
import '../../../onboarding/domain/usecases/get_onboarding_seen.dart';
import '../../domain/is_user_loged_in.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetOnboardingSeen getOnboardingSeen;
  final IsUserLoggedIn isUserLoggedIn;
  final NetworkInfo networkInfo;

  SplashBloc({
    required this.getOnboardingSeen,
    required this.isUserLoggedIn,
    required this.networkInfo,
  }) : super(const SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<RetryConnection>(_onRetryConnection);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      final isOnline = await networkInfo.isConnected;
      final hasSeenOnboarding = await getOnboardingSeen();
      final loggedInResult = await isUserLoggedIn(NoParams());

      if (isOnline) {
        loggedInResult.fold(
          (failure) => emit(const SplashLoaded(route: AppRoutes.onboarding)),
          (isLoggedIn) {
            if (isLoggedIn && hasSeenOnboarding) {
              emit(const SplashLoaded(route: AppRoutes.events));
            } else {
              emit(const SplashLoaded(route: AppRoutes.onboarding));
            }
          },
        );
      } else {
        emit(SplashOffline());
      }
    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }

  Future<void> _onRetryConnection(
    RetryConnection event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      final isOnline = await networkInfo.isConnected;
      if (isOnline) {
        final hasSeenOnboarding = await getOnboardingSeen();
        final loggedInResult = await isUserLoggedIn(NoParams());
        loggedInResult.fold(
          (failure) => emit(const SplashLoaded(route: AppRoutes.onboarding)),
          (isLoggedIn) {
            if (isLoggedIn && hasSeenOnboarding) {
              emit(const SplashLoaded(route: AppRoutes.events));
            } else {
              emit(const SplashLoaded(route: AppRoutes.onboarding));
            }
          },
        );
      } else {
        emit(SplashOffline());
      }
    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }
}
