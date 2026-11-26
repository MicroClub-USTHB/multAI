import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/face_photo_model.dart';
import '../../utils/photo_validator.dart';
import '../../../../core/constants/end_points.dart';

typedef FacePhotoValidator =
    Future<Either<Failure, File>> Function(String filePath);

abstract class FaceEnrollmentRemoteDataSource {
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos);

  /// Whether the signed-in account already has a face enrollment on the
  /// server. The account, not the device, owns the enrollment, so this is the
  /// source of truth across logouts, reinstalls and other devices.
  Future<bool> isEnrollmentDoneOnServer();
}

class FaceEnrollmentRemoteDataSourceImpl
    implements FaceEnrollmentRemoteDataSource {
  final ApiClient apiClient;
  final FacePhotoValidator _validatePhoto;
  static const int _maxRetries = 3;

  FaceEnrollmentRemoteDataSourceImpl({
    required this.apiClient,
    FacePhotoValidator? validatePhoto,
  }) : _validatePhoto = validatePhoto ?? PhotoProcessor.processAndValidate;

  @override
  Future<bool> isEnrollmentDoneOnServer() async {
    final response = await apiClient.get(EndPoints.me);
    if (response is! Map) return false;

    final user = response['user'];
    final source = user is Map ? user : response;
    return source['is_onboarded'] == true;
  }

  @override
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos) async {
    for (final photo in photos) {
      final validation = await _validatePhoto(photo.filePath);
      validation.fold((failure) => throw failure, (_) {});
    }

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
