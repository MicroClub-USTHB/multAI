part of 'account_bloc.dart';

abstract class AccountEvent {}

class LoadAccountData extends AccountEvent {}

class ResetAccountData extends AccountEvent {}

class LogoutRequested extends AccountEvent {}

class ClearImageCacheRequested extends AccountEvent {}

class UploadAvatar extends AccountEvent {
  final String filePath;
  UploadAvatar({required this.filePath});
}
