part of 'account_bloc.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final String name;
  final String email;
  final String? avatarUrl;

  AccountLoaded({required this.name, required this.email, this.avatarUrl});

  AccountLoaded copyWith({String? name, String? email, String? avatarUrl}) {
    return AccountLoaded(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AccountAvatarUploading extends AccountState {
  final String name;
  final String email;
  final String? avatarUrl;

  AccountAvatarUploading({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class AccountError extends AccountState {
  final String message;
  AccountError({required this.message});
}

class AccountLoggedOut extends AccountState {}

class AccountCacheClearing extends AccountState {}

class AccountCacheCleared extends AccountState {
  final String storageFreed;
  final int filesRemoved;

  AccountCacheCleared({required this.storageFreed, required this.filesRemoved});
}
