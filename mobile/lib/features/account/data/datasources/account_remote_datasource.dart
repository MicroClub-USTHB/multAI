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

  @override
  Future<AccountModel> fetchAccountData() async {
    final response = await apiClient.get(EndPoints.me);
    return AccountModel.fromJson(response);
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    final json = await apiClient.postMultipart(
      EndPoints.avatar,
      files: [File(filePath)],
      fieldNames: ['file'],
      requiresAuth: true,
    );
    return json['avatar_url'] as String;
  }

  @override
  Future<AccountModel> updateProfile(String name) async {
    final response = await apiClient.patch(
      EndPoints.updateProfile,
      body: {'name': name},
      requiresAuth: true,
    );
    return AccountModel.fromJson(response);
  }
}
