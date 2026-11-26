import 'dart:convert';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../models/photo_approval_model.dart';

abstract class PhotoApprovalLocalDataSource {
  Future<void> cacheApprovals(List<PhotoApprovalModel> approvals);
  Future<List<PhotoApprovalModel>?> getCachedApprovals();
}

class PhotoApprovalLocalDataSourceImpl implements PhotoApprovalLocalDataSource {
  final AppLocalStorage localStorage;

  PhotoApprovalLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheApprovals(List<PhotoApprovalModel> approvals) async {
    final raw = jsonEncode(approvals.map((a) => a.toJson()).toList());
    await localStorage.setSecureString(StorageKeys.cachedApprovals, raw);
  }

  @override
  Future<List<PhotoApprovalModel>?> getCachedApprovals() async {
    final encrypted = await localStorage.getSecureString(
      StorageKeys.cachedApprovals,
    );
    if (encrypted == null || encrypted.isEmpty) return null;

    try {
      final decoded = jsonDecode(encrypted) as List<dynamic>;
      return decoded
          .map((e) => PhotoApprovalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
