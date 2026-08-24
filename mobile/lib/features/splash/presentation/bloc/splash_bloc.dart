import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/logger.dart';
import '../../../../core/security/device_security.dart';
import '../../../../core/security/secure_logger.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/router/app_routes.dart';
import '../../../onboarding/domain/usecases/get_onboarding_seen.dart';
import '../../../auth/domain/usecases/get_me_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../domain/is_user_loged_in.dart';
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetOnboardingSeen getOnboardingSeen;
  final IsUserLoggedIn isUserLoggedIn;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final Logger _logger;

  SplashBloc({
    required this.getOnboardingSeen,
    required this.isUserLoggedIn,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
    Logger? logger,
  }) : _logger = logger ?? Logger.create(),
       super(const SplashInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<RetryConnection>(_onRetryConnection);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      if (DeviceSecurity.isDebugMode()) {
        SecureLogger.warning('SplashBloc', 'App running in debug mode');
      }

      final isCompromised = await DeviceSecurity.isDeviceCompromised();
      if (isCompromised) {
        SecureLogger.warning('SplashBloc', 'Device is rooted/jailbroken');
        emit(
          const SplashSecurityWarning(
            message: 'This app cannot run on rooted or jailbroken devices.',
          ),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 1500));

      await _resolveSessionAndEmit(emit);
    } catch (e, s) {
      _logger.error('SplashBloc', 'Initialization failed', e, s);
      emit(SplashError(message: 'Could not start the application.'));
    }
  }

  Future<void> _onRetryConnection(
    RetryConnection event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      await _resolveSessionAndEmit(emit);
    } catch (e, s) {
      _logger.error('SplashBloc', 'Retry connection failed', e, s);
      emit(SplashError(message: 'Could not connect. Please try again.'));
    }
  }

  /// Local-first session resolution:
  /// - No token: go straight to onboarding.
  /// - Token present: resolve identity via [GetCurrentUserUseCase], which
  ///   transparently falls back to a cached identity when the network is
  ///   unavailable or the server errors out.
  ///   - Success (fresh or cached): route based on onboarding state.
  ///   - Unauthorized failure: session is genuinely invalid, log out locally
  ///     and send the user to onboarding.
  ///   - Any other failure: truly stuck (no cache, no network) -> offline.
  Future<void> _resolveSessionAndEmit(Emitter<SplashState> emit) async {
    final hasSeenOnboarding = await getOnboardingSeen();
    final loggedInResult = await isUserLoggedIn(NoParams());

    final isLoggedIn = loggedInResult.fold((failure) => false, (v) => v);

    if (!isLoggedIn) {
      emit(const SplashLoaded(route: AppRoutes.onboarding));
      return;
    }

    final meResult = await getCurrentUserUseCase(NoParams());
    await meResult.fold(
      (failure) async {
        if (failure is UnauthorizedFailure) {
          await logoutUseCase(NoParams());
          emit(const SplashLoaded(route: AppRoutes.onboarding));
        } else {
          emit(SplashOffline());
        }
      },
      (user) async {
        emit(
          SplashLoaded(
            route: hasSeenOnboarding
                ? AppRoutes.events
                : AppRoutes.onboarding,
          ),
        );
      },
    );
  }
}
