part of 'face_enrollment_bloc.dart';
 
abstract class FaceEnrollmentState {}
 
class FaceEnrollmentInitial extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos = {};
}
 
class FaceEnrollmentUpdated extends FaceEnrollmentState {
  final Map<FacePhotoType, String> photos;
 
  FaceEnrollmentUpdated({required this.photos});
 
  bool get canSubmit => photos.length == FacePhotoType.values.length;
}
 
class FaceEnrollmentLoading extends FaceEnrollmentState {}
 
class FaceEnrollmentSuccess extends FaceEnrollmentState {}
 
class FaceEnrollmentFailure extends FaceEnrollmentState {
  final String message;
 
  FaceEnrollmentFailure({required this.message});
}
 