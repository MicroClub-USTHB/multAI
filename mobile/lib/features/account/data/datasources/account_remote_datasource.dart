// lib/features/account/data/datasources/account_remote_data_source.dart
import '../models/account_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';

abstract class AccountRemoteDataSource {
  Future<AccountModel> fetchAccountData();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AccountModel> fetchAccountData() async {
    final response = await apiClient.get(EndPoints.account); // API endpoint
    return AccountModel.fromJson(response);
  }
}
