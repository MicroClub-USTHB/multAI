import 'package:flutter_bloc/flutter_bloc.dart';
 
import './../../domain/entities/face_photo_entity.dart';
import './../../domain/usecases/upload_face_photos_usecase.dart';
import './../../domain/usecases/save_enrollment_done_usecase.dart';
import './../../data/utils/photo_validator.dart';
 
part 'face_enrollment_event.dart';
part 'face_enrollment_state.dart';
 
class FaceEnrollmentBloc
    extends Bloc<FaceEnrollmentEvent, FaceEnrollmentState> {
  final UploadFacePhotosUseCase _uploadFacePhotos;
  final SaveEnrollmentDoneUseCase _saveEnrollmentDone;
 
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
 
  // ── Photo selected ─────────────────────────────────────────────────────────
  Future<void> _onPhotoSelected(
    PhotoSelected event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    //  validate file before adding to state
    final validation = await PhotoValidator.validate(event.filePath);
 
    validation.fold(
      (failure) => emit(FaceEnrollmentFailure(message: failure.message)),
      (_) {
        _photos[event.type] = event.filePath;
        emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
      },
    );
  }
 
  // ── Photo removed ──────────────────────────────────────────────────────────
  void _onPhotoRemoved(
    PhotoRemoved event,
    Emitter<FaceEnrollmentState> emit,
  ) {
    _photos.remove(event.type);
    emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
  }
 
  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _onEnrollmentSubmitted(
    EnrollmentSubmitted event,
    Emitter<FaceEnrollmentState> emit,
  ) async {
    emit(FaceEnrollmentLoading());
 
    //  validate all files again before upload
    for (final entry in _photos.entries) {
      final validation = await PhotoValidator.validate(entry.value);
      final failure = validation.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(FaceEnrollmentFailure(message: failure.message));
        return;
      }
    }
 
    final photos = _photos.entries
        .map((e) => FacePhotoEntity(type: e.key, filePath: e.value))
        .toList();
 
    final result = await _uploadFacePhotos(
      UploadFacePhotosParams(photos: photos),
    );
 
    await result.fold(
      (failure) async => emit(FaceEnrollmentFailure(message: failure.message)),
      (_) async {
        await _saveEnrollmentDone();
        emit(FaceEnrollmentSuccess());
      },
    );
  }
}