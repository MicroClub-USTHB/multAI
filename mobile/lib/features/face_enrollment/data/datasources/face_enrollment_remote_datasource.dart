import 'dart:io';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/face_photo_model.dart';
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
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        await apiClient.postMultipart(
          EndPoints.faceEnrollment,
          files: photos.map((p) => File(p.filePath)).toList(),
          fieldNames: List.filled(photos.length, 'files'),
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
