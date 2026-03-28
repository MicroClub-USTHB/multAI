part of 'face_enrollment_bloc.dart';

abstract class FaceEnrollmentEvent {}

class PhotoSelected extends FaceEnrollmentEvent {
  final FacePhotoType type;
  final String filePath;

  PhotoSelected({required this.type, required this.filePath});
}

class PhotoRemoved extends FaceEnrollmentEvent {
  final FacePhotoType type;

  PhotoRemoved({required this.type});
}

class EnrollmentSubmitted extends FaceEnrollmentEvent {}
