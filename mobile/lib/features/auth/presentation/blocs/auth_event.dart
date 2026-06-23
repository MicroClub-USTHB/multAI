part of 'auth_bloc.dart';

abstract class AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;

  RegisterRequested({required this.email, required this.password});
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class RefreshTokenRequested extends AuthEvent {
  final String refreshToken;

  RefreshTokenRequested({required this.refreshToken});
}

class LogoutRequested extends AuthEvent {}

class GetCurrentUserRequested extends AuthEvent {}
