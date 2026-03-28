import 'package:shared_preferences/shared_preferences.dart';

abstract class FaceEnrollmentLocalDataSource {
  Future<bool> isEnrollmentDone();
  Future<void> saveEnrollmentDone();
}

class FaceEnrollmentLocalDataSourceImpl
    implements FaceEnrollmentLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _enrollmentKey = 'is_face_enrollment_done';

  FaceEnrollmentLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isEnrollmentDone() async {
    return sharedPreferences.getBool(_enrollmentKey) ?? false;
  }

  @override
  Future<void> saveEnrollmentDone() async {
    await sharedPreferences.setBool(_enrollmentKey, true);
  }
}
