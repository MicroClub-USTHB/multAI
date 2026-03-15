part of 'auth_bloc.dart';
 
abstract class AuthState {}
 
class AuthInitial extends AuthState {}
 
class AuthLoading extends AuthState {}
 
class AuthSuccess extends AuthState {
  final String accessToken;
 
  AuthSuccess({required this.accessToken});
}
 
class LogoutSuccess extends AuthState {}
 
class GetCurrentUserSuccess extends AuthState {
  final String email;
 
  GetCurrentUserSuccess({required this.email});
}
 
class AuthFailure extends AuthState {
  final String message;
 
  AuthFailure({required this.message});
}
 