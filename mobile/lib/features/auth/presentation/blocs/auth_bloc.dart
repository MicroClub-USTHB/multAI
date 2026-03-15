// ignore_for_file: unused_field
// ─────────────────────────────────────────────────────────────────────────────
// FAKE AuthBloc — UI testing only
// Replace with the real AuthBloc when the data layer is ready
// Events and States have the exact same names as the real ones
// so the UI (login_page.dart) will NOT need any changes
// ─────────────────────────────────────────────────────────────────────────────
 
import 'package:flutter_bloc/flutter_bloc.dart';
 
part 'auth_event.dart';
part 'auth_state.dart';
 
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }
 
  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
 
    // simulate network delay
    await Future.delayed(const Duration(seconds: 2));
 
    // ── to test SUCCESS: comment AuthFailure and uncomment AuthSuccess ────────
    // emit(AuthSuccess(accessToken: 'fake_token_123'));
 
    // ── to test FAILURE: keep this ────────────────────────────────────────────
    emit(AuthFailure(message: 'Invalid email or password'));
  }
 
  // ── Refresh Token ──────────────────────────────────────────────────────────
  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthSuccess(accessToken: 'fake_refreshed_token'));
  }
 
  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(LogoutSuccess());
  }
 
  // ── Get Current User ───────────────────────────────────────────────────────
  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(GetCurrentUserSuccess(email: 'test@multiai.com'));
  }
}
 