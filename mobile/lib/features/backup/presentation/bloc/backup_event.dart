part of 'backup_bloc.dart';

abstract class BackupEvent {}

class LoadBackupInfo extends BackupEvent {}

class StartBackup extends BackupEvent {}

class ShareBackup extends BackupEvent {
  final File zipFile;
  ShareBackup({required this.zipFile});
}
