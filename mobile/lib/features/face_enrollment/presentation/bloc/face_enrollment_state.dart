part of 'face_enrollment_bloc.dart';

abstract class FaceEnrollmentState {}

class FaceEnrollmentInitial extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos = {};
}

class FaceEnrollmentUpdated extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentUpdated({required this.photos});

  bool get canSubmit => photos.canSubmit;
}

class FaceEnrollmentLoading extends FaceEnrollmentState {}

class FaceEnrollmentSuccess extends FaceEnrollmentState {}

class FaceEnrollmentFailure extends FaceEnrollmentState {
  final String message;

  FaceEnrollmentFailure({required this.message});
}

class FaceEnrollmentPhotoLoading extends FaceEnrollmentState {
  final FacePhotoType type;
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentPhotoLoading({required this.type, required this.photos});

  bool get canSubmit => photos.canSubmit;
}

extension CanSubmitExtension on Map<FacePhotoType, String> {
  bool get canSubmit =>
      this[FacePhotoType.frontal] != null &&
      this[FacePhotoType.leftProfile] != null &&
      this[FacePhotoType.rightProfile] != null;
}
