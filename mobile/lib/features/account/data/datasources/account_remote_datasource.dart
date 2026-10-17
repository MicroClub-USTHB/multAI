import 'dart:io';
import '../models/account_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';

abstract class AccountRemoteDataSource {
  Future<AccountModel> fetchAccountData();
  Future<String> uploadAvatar(String filePath);
  Future<AccountModel> updateProfile(String name);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl({required this.apiClient});

  /// The backend returns `avatar_url` as a path relative to the API root
  /// (e.g. `/user/auth/me/avatar/image`), but the widget layer renders it with
  /// `CachedNetworkImage`, which needs an absolute http(s) URL. Resolve it
  /// against [EndPoints.baseUrl] (the same base every API call uses) so the
  /// avatar actually loads.
  static String? toAbsoluteAvatarUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final base = EndPoints.baseUrl;
    if (base.isEmpty) return trimmed;
    if (trimmed.startsWith('/')) return '$base$trimmed';
    return '$base/$trimmed';
  }

  @override
  Future<AccountModel> fetchAccountData() async {
    final response = await apiClient.get(EndPoints.me);
    final model = AccountModel.fromJson(response);
    return AccountModel(
      name: model.name,
      email: model.email,
      avatarUrl: toAbsoluteAvatarUrl(model.avatarUrl),
    );
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final json = await apiClient.postMultipart(
      EndPoints.avatar,
      files: [File(filePath)],
      fieldNames: ['file'],
      requiresAuth: true,
    );
    return toAbsoluteAvatarUrl(json['avatar_url'] as String?) ?? '';
  }

  @override
  Future<AccountModel> updateProfile(String name) async {
    final response = await apiClient.patch(
      EndPoints.updateProfile,
      body: {'name': name},
      requiresAuth: true,
    );
    final model = AccountModel.fromJson(response);
    return AccountModel(
      name: model.name,
      email: model.email,
      avatarUrl: toAbsoluteAvatarUrl(model.avatarUrl),
    );
  }
}
