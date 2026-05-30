import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';

abstract class FaceEnrollmentLocalDataSource {
  Future<bool> isEnrollmentDone();
  Future<void> saveEnrollmentDone();
}

class FaceEnrollmentLocalDataSourceImpl
    implements FaceEnrollmentLocalDataSource {
  final AppLocalStorage localStorage;

  FaceEnrollmentLocalDataSourceImpl({required this.localStorage});

  @override
  Future<bool> isEnrollmentDone() async {
    return localStorage.getBool(StorageKeys.faceEnrollmentDone) ?? false;
  }

  @override
  Future<void> saveEnrollmentDone() async {
    await localStorage.setBool(StorageKeys.faceEnrollmentDone, true);
  }
}
