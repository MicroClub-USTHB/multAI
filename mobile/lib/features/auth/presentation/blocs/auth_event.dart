part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String email;
  final String password;

  SendOtpRequested({required this.email, required this.password});
}

class ResendOtpRequested extends AuthEvent {
  final String pendingToken;

  ResendOtpRequested({required this.pendingToken});
}

class VerifyOtpRequested extends AuthEvent {
  final String email;
  final String password;
  final String otp;

  VerifyOtpRequested({
    required this.email,
    required this.password,
    required this.otp,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

class GetCurrentUserRequested extends AuthEvent {}

class ResetAuth extends AuthEvent {}
