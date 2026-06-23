part of 'face_enrollment_bloc.dart';

abstract class FaceEnrollmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhotoSelected extends FaceEnrollmentEvent {
  final FacePhotoType type;
  final String filePath;

  PhotoSelected({required this.type, required this.filePath});

  @override
  List<Object?> get props => [type, filePath];
}

class PhotoRemoved extends FaceEnrollmentEvent {
  final FacePhotoType type;

  PhotoRemoved({required this.type});

  @override
  List<Object?> get props => [type];
}

class EnrollmentSubmitted extends FaceEnrollmentEvent {}
