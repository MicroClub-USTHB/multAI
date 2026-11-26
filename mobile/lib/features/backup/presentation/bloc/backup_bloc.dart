import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/repositories/backup_repository.dart';

part 'backup_event.dart';
part 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final CreateBackupUseCase _createBackup;
  final BackupRepository _repository;
  final FailureHandler _failureHandler;

  BackupBloc({
    required CreateBackupUseCase createBackup,
    required BackupRepository repository,
    FailureHandler? failureHandler,
  }) : _createBackup = createBackup,
       _repository = repository,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(BackupInitial()) {
    on<LoadBackupInfo>(_onLoadInfo);
    on<StartBackup>(_onStartBackup);
    on<ShareBackup>(_onShareBackup);
  }

  Future<void> _onLoadInfo(
    LoadBackupInfo event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await _repository.getPhotoCount();
    result.fold(
      (failure) => emit(
        BackupError(
          errorPresentation: _failureHandler.getErrorPresentation(failure),
        ),
      ),
      (count) => emit(BackupInfoLoaded(photoCount: count)),
    );
  }

  Future<void> _onStartBackup(
    StartBackup event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupProgress(percent: 0.0, photoCount: 0));

    final pathsResult = await _repository.getCachedPhotoPaths();
    await pathsResult.fold(
      (failure) async {
        emit(
          BackupError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (paths) async {
        if (paths.isEmpty) {
          emit(
            BackupError(
              errorPresentation: ErrorPresentation(
                title: 'No Photos',
                description: 'No cached photos to backup.',
                actionLabel: 'OK',
                action: ErrorAction.none,
                illustration: Icons.photo_library_outlined,
              ),
            ),
          );
          return;
        }

        emit(BackupProgress(percent: 0.0, photoCount: paths.length));

        final result = await _createBackup(
          NoParams(),
          onProgress: (completed, total) {
            if (emit.isDone || total == 0) return;
            emit(
              BackupProgress(
                percent: (completed / total).clamp(0.0, 1.0),
                photoCount: total,
              ),
            );
          },
        );

        result.fold(
          (failure) {
            emit(
              BackupError(
                errorPresentation: _failureHandler.getErrorPresentation(
                  failure,
                ),
              ),
            );
          },
          (zipFile) {
            emit(BackupCompleted(zipFile: zipFile, photoCount: paths.length));
          },
        );
      },
    );
  }

  Future<void> _onShareBackup(
    ShareBackup event,
    Emitter<BackupState> emit,
  ) async {
    try {
      await Share.shareXFiles([
        XFile(event.zipFile.path),
      ], subject: 'MultAI Photo Backup');
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }
}
