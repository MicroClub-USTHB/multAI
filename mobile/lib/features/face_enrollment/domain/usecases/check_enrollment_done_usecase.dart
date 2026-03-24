import '../repositories/face_enrollment_repository.dart';
 
class CheckEnrollmentDoneUseCase {
  final FaceEnrollmentRepository repository;
 
  CheckEnrollmentDoneUseCase(this.repository);
 
  Future<bool> call() => repository.isEnrollmentDone();
}
 