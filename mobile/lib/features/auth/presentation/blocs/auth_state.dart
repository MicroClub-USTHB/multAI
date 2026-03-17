part of 'auth_bloc.dart';
 
abstract class AuthState {}
 
class AuthInitial extends AuthState {}
 
class AuthLoading extends AuthState {}
 
class AuthSuccess extends AuthState {
  final AuthEntity auth;
 
  AuthSuccess({required this.auth});
}
 
class LogoutSuccess extends AuthState {}
 
class GetCurrentUserSuccess extends AuthState {
  final MeEntity user;
 
  GetCurrentUserSuccess({required this.user});
}
 
class AuthFailure extends AuthState {
  final String message;
 
  AuthFailure({required this.message});
}
 