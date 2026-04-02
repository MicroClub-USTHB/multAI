part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthEntity auth;
  AuthAuthenticated({required this.auth});
}

class AuthNeedsFaceEnrollment extends AuthState {
  final AuthEntity auth;
  AuthNeedsFaceEnrollment({required this.auth});
}

class Unauthenticated extends AuthState {}

class GetCurrentUserSuccess extends AuthState {
  final MeEntity user;
  GetCurrentUserSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}
