part of 'backup_bloc.dart';

abstract class BackupState {}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

class BackupInfoLoaded extends BackupState {
  final int photoCount;
  BackupInfoLoaded({required this.photoCount});
}

class BackupProgress extends BackupState {
  final double percent;
  final int photoCount;
  BackupProgress({required this.percent, required this.photoCount});
}

class BackupCompleted extends BackupState {
  final File zipFile;
  final int photoCount;
  BackupCompleted({required this.zipFile, required this.photoCount});
}

class BackupError extends BackupState {
  final ErrorPresentation errorPresentation;
  BackupError({required this.errorPresentation});
}
