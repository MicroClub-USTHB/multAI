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
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/verify_register_usecase.dart';
import '../../utils/device_utils.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ResendOtpUseCase _resendOtpUseCase;
  final VerifyRegisterUseCase _verifyRegisterUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final PushNotificationService _pushNotificationService;
  final FailureHandler _failureHandler;
  final Logger _logger;

  bool _logoutInFlight = false;
  bool get isLoggedOutOrLoggingOut =>
      _logoutInFlight || state is Unauthenticated;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required VerifyRegisterUseCase verifyRegisterUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required PushNotificationService pushNotificationService,
    FailureHandler? failureHandler,
    Logger? logger,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _resendOtpUseCase = resendOtpUseCase,
       _verifyRegisterUseCase = verifyRegisterUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _pushNotificationService = pushNotificationService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       _logger = logger ?? Logger.create(),
       super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<ResetAuth>(_onResetAuth);
  }

  Future<void> _emitAuthenticatedState(
    AuthEntity auth,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(auth: auth));
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
        (pendingToken) async =>
            emit(AuthOtpSent(email: event.email, pendingToken: pendingToken)),
      );
    } catch (e, s) {
      _logger.error('AuthBloc', 'Send OTP failed', e, s);
      emit(AuthFailure(message: 'Failed to send OTP. Please try again.'));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await _resendOtpUseCase(event.pendingToken);
      await result.fold(
        (failure) async => _emitFailure(emit, failure),
        (newPendingToken) async =>
            emit(ResendOtpSuccess(pendingToken: newPendingToken)),
      );
    } catch (e, s) {
      _logger.error('AuthBloc', 'Resend OTP failed', e, s);
      emit(AuthFailure(message: 'Failed to resend OTP. Please try again.'));
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

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    _logoutInFlight = true;
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
    } finally {
      _logoutInFlight = false;
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
      _failureHandler.logFailure(
        UnknownFailure('Could not load user data.'),
        'AuthBloc',
      );
      emit(
        AuthFailure(
          message: _failureHandler.getUserFriendlyMessage(
            const UnknownFailure('Could not load user data.'),
          ),
        ),
      );
    }
  }

  Future<void> _onResetAuth(ResetAuth event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
  }
}
