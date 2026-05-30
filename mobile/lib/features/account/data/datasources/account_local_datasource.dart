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
    await localStorage.setJson(StorageKeys.cachedAccount, account.toJson());
  }

  @override
  Future<AccountModel?> getCachedAccountData() async {
    final cached = localStorage.getJson(StorageKeys.cachedAccount);
    if (cached != null) {
      return AccountModel.fromJson(cached);
    }
    return null;
  }
}
