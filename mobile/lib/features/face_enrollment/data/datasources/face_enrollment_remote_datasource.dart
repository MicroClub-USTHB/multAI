import 'dart:io';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/face_photo_model.dart';
import '../../utils/photo_validator.dart';
import '../../../../core/constants/end_points.dart';

abstract class FaceEnrollmentRemoteDataSource {
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos);
}

class FaceEnrollmentRemoteDataSourceImpl
    implements FaceEnrollmentRemoteDataSource {
  final ApiClient apiClient;
  static const int _maxRetries = 3;

  FaceEnrollmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos) async {
    // Validate each photo before upload
    for (final photo in photos) {
      final validation = await PhotoProcessor.processAndValidate(photo.filePath);
      validation.fold(
        (failure) => throw failure,
        (_) {},
      );
    }

    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        // Use ApiClient to handle HTTP request
        await apiClient.postMultipart(
          EndPoints.faceEnrollment,
          files: photos.map((p) => File(p.filePath)).toList(),
          fieldNames: photos.map((p) => p.fieldName).toList(),
          requiresAuth: true,
        );
        return;
      } on NetworkFailure {
        attempt++;
        if (attempt >= _maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt));
      } on Failure {
        rethrow;
      }
    }
  }
}