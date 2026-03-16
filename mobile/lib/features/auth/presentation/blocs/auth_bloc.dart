

import 'package:flutter_bloc/flutter_bloc.dart';
 
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../utils/device_utils.dart';

 
part 'auth_event.dart';
part 'auth_state.dart';
 

 
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
 
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _refreshTokenUseCase = refreshTokenUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }
 
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    final device = await DeviceUtils.getDeviceData();
 
    final result = await _loginUseCase(
      LoginParams(
        email:       event.email,
        password:    event.password,
        deviceName:  device.deviceName,
        deviceType:  device.deviceType,
        deviceId:    device.deviceId,
        fingerprint: device.fingerprint,
      ),
    );
 
    result.fold(
      (failure) => emit(AuthFailure(message: '')),
      (auth)    => emit(AuthSuccess(auth: auth)),
    );
  }
 
  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    final result = await _refreshTokenUseCase(
      RefreshTokenParams(refreshToken: event.refreshToken),
    );
 
    result.fold(
      (failure) => emit(AuthFailure(message: '')),
      (auth)    => emit(AuthSuccess(auth: auth)),
    );
  }
 
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    final result = await _logoutUseCase(NoParams());
 
    result.fold(
      (failure) => emit(AuthFailure(message: '')),
      (_)       => emit(LogoutSuccess()),
    );
  }
 
  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    final result = await _getCurrentUserUseCase(NoParams());
 
    result.fold(
      (failure) => emit(AuthFailure(message: '')),
      (user)    => emit(GetCurrentUserSuccess(user: user)),
    );
  }
}