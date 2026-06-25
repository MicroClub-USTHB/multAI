import 'dart:convert';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<void> cacheAccountData(AccountModel account);
  Future<AccountModel?> getCachedAccountData();
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final AppLocalStorage localStorage;

  AccountLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheAccountData(AccountModel account) async {
    final raw = jsonEncode(account.toJson());
    await localStorage.setSecureString(StorageKeys.cachedAccount, raw);
  }

  @override
  Future<AccountModel?> getCachedAccountData() async {
    final encrypted = await localStorage.getSecureString(
      StorageKeys.cachedAccount,
    );
    if (encrypted == null || encrypted.isEmpty) return null;

    try {
      final decoded = jsonDecode(encrypted);
      return AccountModel.fromJson(decoded as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
