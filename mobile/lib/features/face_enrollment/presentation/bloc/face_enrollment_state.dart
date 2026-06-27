part of 'face_enrollment_bloc.dart';

enum EnrollmentStatus { editing, submitting, success, failure }

class FaceEnrollmentState extends Equatable {
  final EnrollmentStatus status;
  final Map<FacePhotoType, String> photos;
  final Set<FacePhotoType> loadingPhotoTypes;
  final Map<FacePhotoType, String> photoErrors;
  final String? submitError;

  const FaceEnrollmentState({
    this.status = EnrollmentStatus.editing,
    this.photos = const {},
    this.loadingPhotoTypes = const {},
    this.photoErrors = const {},
    this.submitError,
  });

  bool get canSubmit =>
      status == EnrollmentStatus.editing && photos.hasRequiredPhotos;
  bool get isSubmitting => status == EnrollmentStatus.submitting;
  bool get isSuccess => status == EnrollmentStatus.success;
  bool get isFailure => status == EnrollmentStatus.failure;
  bool get isEditing => status == EnrollmentStatus.editing;
  bool get hasPhotoErrors => photoErrors.isNotEmpty;
  int get completedRequiredCount => photos.requiredCount;
  int get completedOptionalCount => photos.optionalCount;
  int get totalRequired => FacePhotoType.required.length;
  int get totalOptional => FacePhotoType.optional.length;

  FaceEnrollmentState copyWith({
    EnrollmentStatus? status,
    Map<FacePhotoType, String>? photos,
    Set<FacePhotoType>? loadingPhotoTypes,
    Map<FacePhotoType, String>? photoErrors,
    String? submitError,
    bool clearPhotoErrors = false,
  }) {
    return FaceEnrollmentState(
      status: status ?? this.status,
      photos: photos != null ? Map.unmodifiable(photos) : this.photos,
      loadingPhotoTypes:
          loadingPhotoTypes ?? this.loadingPhotoTypes,
      photoErrors: clearPhotoErrors
          ? const {}
          : (photoErrors != null
              ? Map.unmodifiable(photoErrors)
              : this.photoErrors),
      submitError: submitError,
    );
  }

  Map<FacePhotoType, String> addPhoto(FacePhotoType type, String path) {
    final next = Map<FacePhotoType, String>.from(photos);
    next[type] = path;
    return next;
  }

  Map<FacePhotoType, String> removePhoto(FacePhotoType type) {
    final next = Map<FacePhotoType, String>.from(photos);
    next.remove(type);
    return next;
  }

  Map<FacePhotoType, String> addPhotoError(FacePhotoType type, String msg) {
    final next = Map<FacePhotoType, String>.from(photoErrors);
    next[type] = msg;
    return next;
  }

  Set<FacePhotoType> toggleLoading(FacePhotoType type, bool add) {
    final next = Set<FacePhotoType>.from(loadingPhotoTypes);
    if (add) { next.add(type); } else { next.remove(type); }
    return next;
  }

  Map<FacePhotoType, String> removeError(FacePhotoType type) {
    final next = Map<FacePhotoType, String>.from(photoErrors);
    next.remove(type);
    return next;
  }

  @override
  List<Object?> get props => [
        status,
        photos,
        loadingPhotoTypes,
        photoErrors,
        submitError,
      ];
}
