import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/logger.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../features/notifications/services/push_notification_service.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_register_usecase.dart';
import '../../utils/device_utils.dart';
import '../../../face_enrollment/domain/usecases/check_enrollment_done_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyRegisterUseCase _verifyRegisterUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckEnrollmentDoneUseCase _checkEnrollmentDone;
  final PushNotificationService _pushNotificationService;
  final FailureHandler _failureHandler;
  final Logger _logger;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyRegisterUseCase verifyRegisterUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckEnrollmentDoneUseCase checkEnrollmentDone,
    required PushNotificationService pushNotificationService,
    FailureHandler? failureHandler,
    Logger? logger,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _verifyRegisterUseCase = verifyRegisterUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _checkEnrollmentDone = checkEnrollmentDone,
       _pushNotificationService = pushNotificationService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       _logger = logger ?? Logger.create(),
       super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _emitAuthenticatedState(
    AuthEntity auth,
    Emitter<AuthState> emit,
  ) async {
    final isDone = await _checkEnrollmentDone();
    if (isDone) {
      emit(AuthAuthenticated(auth: auth));
    } else {
      emit(AuthNeedsFaceEnrollment(auth: auth));
    }
  }

  void _emitFailure(Emitter<AuthState> emit, Failure failure) {
    _failureHandler.logFailure(failure, 'AuthBloc');
    emit(AuthFailure(message: _failureHandler.getUserFriendlyMessage(failure)));
  }

  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final device = await DeviceUtils.getDeviceData();
      final result = await _registerUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          deviceId: device.deviceId,
        ),
      );
      await result.fold(
        (failure) async => _emitFailure(emit, failure),
        (_) async => emit(AuthOtpSent(email: event.email)),
      );
    } catch (e, s) {
      _logger.error('AuthBloc', 'Send OTP failed', e, s);
      emit(AuthFailure(message: 'Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final device = await DeviceUtils.getDeviceData();
      final result = await _verifyRegisterUseCase(
        VerifyRegisterParams(
          loginParams: LoginParams(
            email: event.email,
            password: event.password,
            deviceName: device.deviceName,
            deviceType: device.deviceType,
            deviceId: device.deviceId,
          ),
          otp: event.otp,
        ),
      );
      await result.fold((failure) async => _emitFailure(emit, failure), (
        auth,
      ) async {
        await _pushNotificationService.registerCurrentToken();
        await _emitAuthenticatedState(auth, emit);
      });
    } catch (e, s) {
      _logger.error('AuthBloc', 'Verify OTP failed', e, s);
      emit(AuthFailure(message: 'Verification failed. Please try again.'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final device = await DeviceUtils.getDeviceData();
      final result = await _loginUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          deviceId: device.deviceId,
        ),
      );
      await result.fold((failure) async => _emitFailure(emit, failure), (
        auth,
      ) async {
        await _pushNotificationService.registerCurrentToken();
        await _emitAuthenticatedState(auth, emit);
      });
    } catch (e, s) {
      _logger.error('AuthBloc', 'Login failed', e, s);
      emit(AuthFailure(message: 'Sign in failed. Please try again.'));
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _refreshTokenUseCase(
        RefreshTokenParams(refreshToken: event.refreshToken),
      );
      result.fold(
        (failure) => _emitFailure(emit, failure),
        (auth) => _emitAuthenticatedState(auth, emit),
      );
    } catch (e, s) {
      _logger.error('AuthBloc', 'Token refresh failed', e, s);
      emit(AuthFailure(message: 'Session expired. Please sign in again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _pushNotificationService.revokeToken();
      final result = await _logoutUseCase(NoParams());
      await DeviceUtils.clearDeviceId();
      result.fold((failure) {
        _failureHandler.logFailure(failure, 'AuthBloc');
        emit(Unauthenticated());
      }, (_) => emit(Unauthenticated()));
    } catch (e, s) {
      _logger.error('AuthBloc', 'Logout failed', e, s);
      emit(Unauthenticated());
    }
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _getCurrentUserUseCase(NoParams());
      result.fold(
        (failure) => _emitFailure(emit, failure),
        (user) => emit(GetCurrentUserSuccess(user: user)),
      );
    } catch (e, s) {
      _logger.error('AuthBloc', 'Get current user failed', e, s);
      emit(AuthFailure(message: 'Could not load user data.'));
    }
  }
}
