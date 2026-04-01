import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multai_mobile/features/auth/domain/repositories/auth_repository.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../utils/device_utils.dart';
import '../../../face_enrollment/domain/usecases/check_enrollment_done_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckEnrollmentDoneUseCase _checkEnrollmentDone;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckEnrollmentDoneUseCase checkEnrollmentDone,
  }) : _loginUseCase = loginUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _checkEnrollmentDone = checkEnrollmentDone,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  // ── Login
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
          platform: device.platform,
          deviceId: device.deviceId,
          deviceFingerprint: device.deviceFingerprint,
        ),
      );

      await result.fold(
        (failure) async => emit(AuthFailure(message: failure.message)),
        (auth) async {
          final isDone = await _checkEnrollmentDone();

          if (isDone) {
            emit(AuthAuthenticated(auth: auth));
          } else {
            emit(AuthNeedsFaceEnrollment(auth: auth));
          }
        },
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  // ── Refresh token
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
        (failure) => emit(AuthFailure(message: failure.message)),
        (auth) => emit(
          AuthAuthenticated(auth: auth),
        ), // assume enrollment done if token refreshed
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  // ── Logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _logoutUseCase(NoParams());

      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (_) => emit(LogoutSuccess()),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  // ── Get current user
  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _getCurrentUserUseCase(NoParams());

      result.fold(
        (failure) => emit(AuthFailure(message: failure.message)),
        (user) => emit(GetCurrentUserSuccess(user: user)),
      );
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
