import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
 
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';
import '../models/face_photo_model.dart';
import '../utils/photo_validator.dart';
 
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
    // ── 1. check connection ────────────────────────────────────────────────
    await apiClient.checkConnection();
 
    // ── 2. validate all photos before upload ──────────────────────────────
    for (final photo in photos) {
      final validation = await PhotoValidator.validate(photo.filePath);
      validation.fold(
        (failure) => throw failure,
        (_) {},
      );
    }
 
    // ── 3. upload with retry logic ─────────────────────────────────────────
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        await _upload(photos);
        return;
      } on NetworkFailure {
        attempt++;
        if (attempt >= _maxRetries) rethrow;
        // wait before retry: 1s, 2s, 3s
        await Future.delayed(Duration(seconds: attempt));
      } on Failure {
        rethrow; // don't retry non-network failures
      }
    }
  }
 
  Future<void> _upload(List<FacePhotoModel> photos) async {
    final uri = Uri.parse('${apiClient.baseUrl}${EndPoints.faceEnrollment}');
    final request = http.MultipartRequest('POST', uri);
 
    // ── auth header ────────────────────────────────────────────────────────
    if (apiClient.currentAccessToken != null) {
      request.headers['Authorization'] =
          'Bearer ${apiClient.currentAccessToken}';
    }
 
    // ── attach each photo ──────────────────────────────────────────────────
    for (final photo in photos) {
      final file = File(photo.filePath);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
 
      //  detect real format instead of hardcoding jpeg
      final contentType = PhotoValidator.getContentType(photo.filePath);
 
      request.files.add(
        http.MultipartFile(
          photo.fieldName,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType('image', contentType),
        ),
      );
    }
 
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
 
    if (response.statusCode == 401) {
      throw const UnauthorizedFailure(
          message: 'Session expired. Please log in again.');
    }
 
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure(
        message: 'Failed to upload photos. Please try again.',
      );
    }
  }
}
 