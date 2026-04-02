import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<void> cacheAccountData(AccountModel account);
  Future<AccountModel?> getCachedAccountData();
}

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const _accountKey = 'CACHED_ACCOUNT';

  AccountLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAccountData(AccountModel account) async {
    final jsonString = jsonEncode(account.toJson());
    await sharedPreferences.setString(_accountKey, jsonString);
  }

  @override
  Future<AccountModel?> getCachedAccountData() async {
    final jsonString = sharedPreferences.getString(_accountKey);
    if (jsonString != null) {
      return AccountModel.fromJson(jsonDecode(jsonString));
    }
    return null;
  }
}
