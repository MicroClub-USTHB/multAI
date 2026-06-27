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

  final Map<FacePhotoType, String> _photos = {};

  FaceEnrollmentBloc({
    required UploadFacePhotosUseCase uploadFacePhotos,
    required SaveEnrollmentDoneUseCase saveEnrollmentDone,
    FailureHandler? failureHandler,
  }) : _uploadFacePhotos = uploadFacePhotos,
       _saveEnrollmentDone = saveEnrollmentDone,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(FaceEnrollmentInitial()) {
    on<PhotoSelected>(_onPhotoSelected);
    on<PhotoRemoved>(_onPhotoRemoved);
    on<EnrollmentSubmitted>(_onEnrollmentSubmitted);
  }

  Future<void> _onPhotoSelected(
    PhotoSelected event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    emit(
      FaceEnrollmentPhotoLoading(type: event.type, photos: Map.from(_photos)),
    );

    final result = await PhotoProcessor.processAndValidate(event.filePath);

    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'FaceEnrollmentBloc');
        emit(
          FaceEnrollmentFailure(
            message: _failureHandler.getUserFriendlyMessage(failure),
            photos: Map.from(_photos),
          ),
        );
      },
      (compressedFile) {
        _photos[event.type] = compressedFile.path;
        emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
      },
    );
  }

  void _onPhotoRemoved(PhotoRemoved event, Emitter<FaceEnrollmentState> emit) {
    _photos.remove(event.type);
    emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
  }

  Future<void> _onEnrollmentSubmitted(
    EnrollmentSubmitted event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    emit(FaceEnrollmentLoading());

    final photos = _photos.entries
        .map((e) => FacePhotoEntity(type: e.key, filePath: e.value))
        .toList();

    try {
      final result = await _uploadFacePhotos(
        UploadFacePhotosParams(photos: photos),
      );

      await result.fold(
        (failure) async {
          _failureHandler.logFailure(failure, 'FaceEnrollmentBloc');
          emit(
            FaceEnrollmentFailure(
              message: _failureHandler.getUserFriendlyMessage(failure),
            ),
          );
        },
        (_) async {
          await _saveEnrollmentDone();
          emit(FaceEnrollmentSuccess());
        },
      );
    } catch (e) {
      _failureHandler.logFailure(
        UnknownFailure('Enrollment failed'),
        'FaceEnrollmentBloc',
      );
      emit(
        FaceEnrollmentFailure(
          message: _failureHandler.getUserFriendlyMessage(
            const UnknownFailure('Enrollment failed'),
          ),
        ),
      );
    }
  }
}
