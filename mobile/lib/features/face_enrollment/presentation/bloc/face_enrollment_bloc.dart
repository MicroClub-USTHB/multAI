import 'package:flutter_bloc/flutter_bloc.dart';
 
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
 
  //  stores COMPRESSED file paths — not original
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
    // emit loading per photo so UI shows spinner on the slot
    emit(FaceEnrollmentPhotoLoading(
      type: event.type,
      photos: Map.from(_photos),
    ));
 
    //  validate + compress in BLoC — never in UI
    final validation = await PhotoValidator.validate(event.filePath);
 
    validation.fold(
      (failure) {
        // restore previous state on failure
        emit(FaceEnrollmentUpdated(photos: Map.from(_photos)));
        emit(FaceEnrollmentFailure(message: failure.message));
      },
      (compressedFile) {
        //  store compressed path — not original
        _photos[event.type] = compressedFile.path;
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
 
    // no double validation — photos already compressed and validated
    // just build the entities from stored compressed paths
    final photos = _photos.entries
        .map((e) => FacePhotoEntity(type: e.key, filePath: e.value))
        .toList();
 
    final result = await _uploadFacePhotos(
      UploadFacePhotosParams(photos: photos),
    );
 
    await result.fold(
      (failure) async =>
          emit(FaceEnrollmentFailure(message: failure.message)),
      (_) async {
        await _saveEnrollmentDone();
        emit(FaceEnrollmentSuccess());
      },
    );
  }
}



