import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_client.dart';
 
import '../../../../core/errors/failure.dart';
import '../../../../core/constants/end_points.dart';
import '../models/face_photo_model.dart';
 
abstract class FaceEnrollmentRemoteDataSource {
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos);
}
 
class FaceEnrollmentRemoteDataSourceImpl
    implements FaceEnrollmentRemoteDataSource {
  final ApiClient apiClient;
 
  FaceEnrollmentRemoteDataSourceImpl({required this.apiClient});
 
  @override
  Future<void> uploadFacePhotos(List<FacePhotoModel> photos) async {
    // ── check connection via ApiClient ─────────────────────────────────────
    await apiClient.checkConnection();
 
    final uri = Uri.parse('${apiClient.baseUrl}${EndPoints.faceEnrollment}');
    final request = http.MultipartRequest('POST', uri);
 
    // ── auth header from ApiClient ─────────────────────────────────────────
    if (apiClient.currentAccessToken != null) {
      request.headers['Authorization'] =
          'Bearer ${apiClient.currentAccessToken}';
    }
 
    // ── attach each photo as multipart file ────────────────────────────────
    for (final photo in photos) {
      final file = File(photo.filePath);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
 
      request.files.add(
        http.MultipartFile(
          photo.fieldName,
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
 
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
 
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure(
        message: 'Failed to upload photos. Please try again.',
      );
    }
  }
}