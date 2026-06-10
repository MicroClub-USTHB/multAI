part of 'face_enrollment_bloc.dart';

abstract class FaceEnrollmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FaceEnrollmentInitial extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentInitial({this.photos = const {}});

  @override
  List<Object?> get props => [photos];
}

class FaceEnrollmentUpdated extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentUpdated({required this.photos});

  bool get canSubmit => photos.canSubmit;

  @override
  List<Object?> get props => [photos];
}

class FaceEnrollmentLoading extends FaceEnrollmentState {}

class FaceEnrollmentSuccess extends FaceEnrollmentState {}

class FaceEnrollmentFailure extends FaceEnrollmentState {
  final String message;
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentFailure({required this.message, this.photos = const {}});

  @override
  List<Object?> get props => [message, photos];
}

class FaceEnrollmentPhotoLoading extends FaceEnrollmentState {
  final FacePhotoType type;
  final Map<FacePhotoType, String> photos;

  FaceEnrollmentPhotoLoading({required this.type, required this.photos});

  bool get canSubmit => photos.canSubmit;

  @override
  List<Object?> get props => [type, photos];
}

extension CanSubmitExtension on Map<FacePhotoType, String> {
  bool get canSubmit =>
      this[FacePhotoType.frontal] != null &&
      this[FacePhotoType.leftProfile] != null &&
      this[FacePhotoType.rightProfile] != null;
}
