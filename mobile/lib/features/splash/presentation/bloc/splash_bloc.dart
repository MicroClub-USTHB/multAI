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
part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetOnboardingSeen getOnboardingSeen;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  final Logger _logger;

  SplashBloc({
    required this.getOnboardingSeen,
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

  /// Local-first session resolution. We never gate on raw token presence —
  /// [GetCurrentUserUseCase] already knows how to fall back to a cached
  /// identity when there's no network, no server, or (now) no access token
  /// at all, so it's always worth asking it first:
  ///   - Success (fresh from network OR served from cache): route based on
  ///     onboarding state.
  ///   - Unauthorized failure: no valid credentials AND no cached identity
  ///     to fall back to — this is genuinely "not logged in". Clear any
  ///     leftover local session state and send the user to onboarding.
  ///   - Any other failure: there IS a session, we just couldn't verify it
  ///     (offline/server error) and have nothing cached either -> offline.
  Future<void> _resolveSessionAndEmit(Emitter<SplashState> emit) async {
    final hasSeenOnboarding = await getOnboardingSeen();

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
