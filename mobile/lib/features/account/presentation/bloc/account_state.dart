
part of 'account_bloc.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final String name;
  final String email;
  final String membershipType;
  final String? avatarUrl;

  AccountLoaded({
    required this.name,
    required this.email,
    required this.membershipType,
    this.avatarUrl,
  });
}

class AccountError extends AccountState {
  final String message;
  AccountError({required this.message});
}

class AccountLoggedOut extends AccountState {}
