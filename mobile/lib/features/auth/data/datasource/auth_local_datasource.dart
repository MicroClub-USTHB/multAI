import 'dart:convert';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../models/me_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheMe(MeResponseModel me);
  Future<MeResponseModel?> getCachedMe();
  Future<void> clearCachedMe();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppLocalStorage localStorage;

  AuthLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheMe(MeResponseModel me) async {
    final raw = jsonEncode(me.toJson());
    await localStorage.setSecureString(StorageKeys.cachedMe, raw);
  }

  @override
  Future<MeResponseModel?> getCachedMe() async {
    final encrypted = await localStorage.getSecureString(StorageKeys.cachedMe);
    if (encrypted == null || encrypted.isEmpty) return null;

    try {
      final decoded = jsonDecode(encrypted);
      return MeResponseModel.fromJson(decoded as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCachedMe() async {
    await localStorage.removeSecure(StorageKeys.cachedMe);
  }
}
