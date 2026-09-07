import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../domain/entities/face_photo_entity.dart';
import '../../domain/usecases/upload_face_photos_usecase.dart';
import '../../domain/usecases/save_enrollment_done_usecase.dart';
import '../../utils/photo_validator.dart';

part 'face_enrollment_event.dart';
part 'face_enrollment_state.dart';

class FaceEnrollmentBloc
    extends Bloc<FaceEnrollmentEvent, FaceEnrollmentState> {
  final UploadFacePhotosUseCase _uploadFacePhotos;
  final SaveEnrollmentDoneUseCase _saveEnrollmentDone;
  final FailureHandler _failureHandler;
  final Set<String> _tempFiles = {};

  FaceEnrollmentBloc({
    required UploadFacePhotosUseCase uploadFacePhotos,
    required SaveEnrollmentDoneUseCase saveEnrollmentDone,
    required FailureHandler failureHandler,
  }) : _uploadFacePhotos = uploadFacePhotos,
       _saveEnrollmentDone = saveEnrollmentDone,
       _failureHandler = failureHandler,
       super(const FaceEnrollmentState()) {
    on<PhotoSelected>(_onPhotoSelected);
    on<PhotoRemoved>(_onPhotoRemoved);
    on<EnrollmentSubmitted>(_onEnrollmentSubmitted);
    on<ResetEnrollment>(_onResetEnrollment);
  }

  Future<void> _onPhotoSelected(
    PhotoSelected event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    if (_shouldRejectInteraction()) return;

    _emitLoading(event.type, emit);

    final result = await PhotoProcessor.processAndValidate(event.filePath);

    if (emit.isDone) return;

    result.fold((failure) => _emitPhotoError(event.type, failure, emit), (
      compressedFile,
    ) {
      _safeDeleteOldPhoto(event.type);
      _trackTempFile(compressedFile.path);
      _emitPhotoAdded(event.type, compressedFile.path, emit);
    });
  }

  void _onPhotoRemoved(PhotoRemoved event, Emitter<FaceEnrollmentState> emit) {
    if (_shouldRejectInteraction()) return;

    _safeDeletePhoto(event.type);
    emit(
      state.copyWith(
        photos: state.removePhoto(event.type),
        photoErrors: state.removeError(event.type),
      ),
    );
  }

  Future<void> _onEnrollmentSubmitted(
    EnrollmentSubmitted event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: EnrollmentStatus.submitting));

    final photos = state.photos.entries
        .map((e) => FacePhotoEntity(type: e.key, filePath: e.value))
        .toList();

    final uploadResult = await _uploadFacePhotos(
      UploadFacePhotosParams(photos: photos),
    );

    if (emit.isDone) return;

    await uploadResult.fold(
      (failure) async {
        _failureHandler.logFailure(failure, 'FaceEnrollmentBloc');
        emit(
          state.copyWith(
            status: EnrollmentStatus.editing,
            submitError: _failureHandler.getUserFriendlyMessage(failure),
          ),
        );
      },
      (_) async {
        try {
          await _saveEnrollmentDone();
        } catch (e) {
          if (emit.isDone) return;
          _failureHandler.logFailure(
            UnknownFailure('Failed to save enrollment status'),
            'FaceEnrollmentBloc',
          );
          emit(
            state.copyWith(
              status: EnrollmentStatus.editing,
              submitError: _failureHandler.getUserFriendlyMessage(
                const UnknownFailure('Failed to save enrollment status'),
              ),
            ),
          );
          return;
        }

        if (emit.isDone) return;
        _cleanupTempFiles();
        emit(state.copyWith(status: EnrollmentStatus.success));
      },
    );
  }

  void _onResetEnrollment(
    ResetEnrollment event,
    Emitter<FaceEnrollmentState> emit,
  ) {
    _cleanupTempFiles();
    emit(const FaceEnrollmentState());
  }

  bool _shouldRejectInteraction() => state.isSubmitting || state.isSuccess;

  void _emitLoading(FacePhotoType type, Emitter<FaceEnrollmentState> emit) {
    emit(
      state.copyWith(
        loadingPhotoTypes: state.toggleLoading(type, true),
        photoErrors: state.removeError(type),
      ),
    );
  }

  void _emitPhotoAdded(
    FacePhotoType type,
    String path,
    Emitter<FaceEnrollmentState> emit,
  ) {
    emit(
      state.copyWith(
        photos: state.addPhoto(type, path),
        loadingPhotoTypes: state.toggleLoading(type, false),
      ),
    );
  }

  void _emitPhotoError(
    FacePhotoType type,
    Failure failure,
    Emitter<FaceEnrollmentState> emit,
  ) {
    _failureHandler.logFailure(failure, 'FaceEnrollmentBloc');
    emit(
      state.copyWith(
        loadingPhotoTypes: state.toggleLoading(type, false),
        photoErrors: state.addPhotoError(
          type,
          _failureHandler.getUserFriendlyMessage(failure),
        ),
      ),
    );
  }

  void _trackTempFile(String path) {
    _tempFiles.add(path);
  }

  void _safeDeletePhoto(FacePhotoType type) {
    final path = state.photos[type];
    if (path != null) {
      _safeDeleteFile(path);
      _tempFiles.remove(path);
    }
  }

  void _safeDeleteOldPhoto(FacePhotoType type) {
    final oldPath = state.photos[type];
    if (oldPath != null) {
      _safeDeleteFile(oldPath);
      _tempFiles.remove(oldPath);
    }
  }

  void _cleanupTempFiles() {
    for (final path in _tempFiles) {
      _safeDeleteFile(path);
    }
    _tempFiles.clear();
  }

  void _safeDeleteFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _cleanupTempFiles();
    return super.close();
  }
}
