import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';
import '../models/photo_model.dart';

abstract class PhotoRemoteDataSource {
  Future<List<PhotoModel>> getMyPhotos({
    String? eventId,
    String sort,
    int limit,
    int offset,
  });

  Future<({List<PhotoModel> items, int total})> getEventPhotos({
    required String eventId,
    String sort,
    int limit,
    int offset,
  });

  // returns raw bytes for caching
  Future<Uint8List> getPhotoImageBytes(String photoId);
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final ApiClient apiClient;

  PhotoRemoteDataSourceImpl({required this.apiClient});

  // GET /photos?event_id=&sort=&limit=&offset=
  @override
  Future<List<PhotoModel>> getMyPhotos({
    String? eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    final query = StringBuffer('?sort=$sort&limit=$limit&offset=$offset');
    if (eventId != null) query.write('&event_id=$eventId');

    final json = await apiClient.get('${EndPoints.photos}$query');

    // response is a list directly
    final list =
        json['data'] as List<dynamic>? ??
        (json is List ? json : []);

    return list
        .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET /photos/event/{event_id}?sort=&limit=&offset=
  @override
  Future<({List<PhotoModel> items, int total})> getEventPhotos({
    required String eventId,
    String sort = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    final query = '?sort=$sort&limit=$limit&offset=$offset';
    final json = await apiClient.get(
      '${EndPoints.photos}/event/$eventId$query',
    );

    final total = json['total'] as int? ?? 0;
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (items: items, total: total);
  }

  // GET /photos/{photo_id}/image — raw bytes
  @override
  Future<Uint8List> getPhotoImageBytes(String photoId) async {
    await apiClient.checkConnection();

    final uri = Uri.parse(
      '${apiClient.baseUrl}${EndPoints.photos}/$photoId/image',
    );
    final response = await http.get(
      uri,
      headers: {
        if (apiClient.currentAccessToken != null)
          'Authorization': 'Bearer ${apiClient.currentAccessToken}',
      },
    );

    if (response.statusCode == 200) return response.bodyBytes;

    throw Exception(
      'Failed to download photo $photoId: ${response.statusCode}',
    );
  }
}
