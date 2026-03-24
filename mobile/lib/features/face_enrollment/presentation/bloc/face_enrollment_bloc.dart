import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/face_photo_entity.dart';
import '../../domain/usecases/upload_face_photos_usecase.dart';
import '../../domain/usecases/save_enrollment_done_usecase.dart';
import '../../utils/photo_validator.dart';

part 'face_enrollment_event.dart';
part 'face_enrollment_state.dart';

/// Bloc responsible for managing face enrollment
/// Handles photo selection, removal, validation, and upload
class FaceEnrollmentBloc
    extends Bloc<FaceEnrollmentEvent, FaceEnrollmentState> {
  final UploadFacePhotosUseCase _uploadFacePhotos;
  final SaveEnrollmentDoneUseCase _saveEnrollmentDone;

  /// Stores compressed photo file paths
  final Map<FacePhotoType, String> _photos = {};

  FaceEnrollmentBloc({
    required UploadFacePhotosUseCase uploadFacePhotos,
    required SaveEnrollmentDoneUseCase saveEnrollmentDone,
  })  : _uploadFacePhotos = uploadFacePhotos,
        _saveEnrollmentDone = saveEnrollmentDone,
        super(FaceEnrollmentInitial()) {
    on<PhotoSelected>(_onPhotoSelected);
    on<PhotoRemoved>(_onPhotoRemoved);
    on<EnrollmentSubmitted>(_onEnrollmentSubmitted);
  }

  /// Handles photo selection
  Future<void> _onPhotoSelected(
    PhotoSelected event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    emit(FaceEnrollmentPhotoLoading(
      type: event.type,
      photos: Map.from(_photos),
    ));

    final validation = await PhotoValidator.validate(event.filePath);

    validation.fold(
      (failure) {
        // Restore previous photos on failure
        emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
        emit(FaceEnrollmentFailure(message: failure.message));
      },
      (compressedFile) {
        _photos[event.type] = compressedFile.path;
        emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
      },
    );
  }

  /// Handles photo removal
  void _onPhotoRemoved(
    PhotoRemoved event,
    Emitter<FaceEnrollmentState> emit,
  ) {
    _photos.remove(event.type);
    emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
  }

  /// Handles enrollment submission
  Future<void> _onEnrollmentSubmitted(
    EnrollmentSubmitted event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    emit(FaceEnrollmentLoading());

    final photos = _photos.entries
        .map((e) => FacePhotoEntity(type: e.key, filePath: e.value))
        .toList();

    final result = await _uploadFacePhotos(
      UploadFacePhotosParams(photos: photos),
    );

    result.fold(
      (failure) => emit(FaceEnrollmentFailure(message: failure.message)),
      (_) async {
        await _saveEnrollmentDone();
        emit(FaceEnrollmentSuccess());
      },
    );
  }

  /// Returns a copy of current photos (read-only)
  Map<FacePhotoType, String> get photos => Map.unmodifiable(_photos);

  /// Determines if submission is allowed (e.g., at least 3 photos)
  bool get canSubmit => _photos.length >= 3; // adjust as needed
}