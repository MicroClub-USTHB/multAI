import '../repositories/face_enrollment_repository.dart';

class SaveEnrollmentDoneUseCase {
  final FaceEnrollmentRepository repository;

  SaveEnrollmentDoneUseCase(this.repository);

  Future<void> call() => repository.saveEnrollmentDone();
}
