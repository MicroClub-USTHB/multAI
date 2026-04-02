part of 'account_bloc.dart';

abstract class AccountEvent {}

class LoadAccountData extends AccountEvent {}

class LogoutRequested extends AccountEvent {}
