part of 'account_bloc.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? avatarCacheKey;
  final String cacheSize;
  final int cacheFiles;

  AccountLoaded({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.avatarCacheKey,
    this.cacheSize = '0 B',
    this.cacheFiles = 0,
  });

  AccountLoaded copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? avatarCacheKey,
    String? cacheSize,
    int? cacheFiles,
  }) {
    return AccountLoaded(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarCacheKey: avatarCacheKey ?? this.avatarCacheKey,
      cacheSize: cacheSize ?? this.cacheSize,
      cacheFiles: cacheFiles ?? this.cacheFiles,
    );
  }
}

class AccountAvatarUploading extends AccountState {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? avatarCacheKey;

  AccountAvatarUploading({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.avatarCacheKey,
  });
}

class AccountProfileUpdating extends AccountState {
  final String name;
  final String email;
  final String? avatarUrl;
  final String? avatarCacheKey;

  AccountProfileUpdating({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.avatarCacheKey,
  });
}

class AccountError extends AccountState {
  final ErrorPresentation errorPresentation;
  AccountError({required this.errorPresentation});
}

class AccountLoggedOut extends AccountState {}

class AccountCacheClearing extends AccountState {}

class AccountCacheCleared extends AccountState {
  final String storageFreed;
  final int filesRemoved;

  AccountCacheCleared({required this.storageFreed, required this.filesRemoved});
}
