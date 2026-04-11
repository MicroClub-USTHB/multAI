import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';
import '../models/photo_approval_model.dart';

abstract class PhotoApprovalRemoteDataSource {
  Future<List<PhotoApprovalModel>> getApprovals({
    String? status,
    int limit,
    int offset,
  });

  Future<String> decide({required String photoId, required String decision});
}

class PhotoApprovalRemoteDataSourceImpl
    implements PhotoApprovalRemoteDataSource {
  final ApiClient apiClient;

  PhotoApprovalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PhotoApprovalModel>> getApprovals({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = StringBuffer('?limit=$limit&offset=$offset');
    if (status != null) query.write('&status=$status');

    final json = await apiClient.get('${EndPoints.photoApprovals}$query');

    final list =
        json['data'] as List<dynamic>? ??
        (json is List ? json as List<dynamic> : []);

    return list
        .map((e) => PhotoApprovalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> decide({
    required String photoId,
    required String decision,
  }) async {
    final json = await apiClient.post(
      '${EndPoints.photoDecision}/$photoId/decision',
      body: {'decision': decision},
      requiresAuth: true,
    );
    return json['photo_status'] as String? ?? '';
  }
}
