import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/constants/device_constants.dart';

class DeviceData {
  final String deviceName;
  final String deviceType;
  final String deviceId;
  const DeviceData({
    required this.deviceName,
    required this.deviceType,
    required this.deviceId,
  });
}

class DeviceUtils {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();
  static final AndroidId _androidIdPlugin = AndroidId();
  static final Uuid _uuid = Uuid();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<DeviceData> getDeviceData() async {
    const testDeviceId = String.fromEnvironment('TEST_DEVICE_ID');
    const testDeviceName = String.fromEnvironment('TEST_DEVICE_NAME');
    const testDeviceType = String.fromEnvironment('TEST_DEVICE_TYPE');
    if (testDeviceId.isNotEmpty &&
        testDeviceName.isNotEmpty &&
        testDeviceType.isNotEmpty) {
      return DeviceData(
        deviceName: testDeviceName,
        deviceType: testDeviceType,
        deviceId: testDeviceId,
      );
    }

    final currentData = await _buildCurrentDeviceData();

    String deviceId;
    if (currentData.deviceId.isNotEmpty) {
      deviceId = _uuid.v5(DeviceConstants.uuidNamespace, currentData.deviceId);
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
    } else {
      final storedDeviceId = await _storage.read(key: StorageKeys.deviceId);
      deviceId = storedDeviceId?.trim().isNotEmpty == true
          ? storedDeviceId!.trim()
          : _uuid.v4();
      if (storedDeviceId == null || storedDeviceId.trim().isEmpty) {
        await _storage.write(key: StorageKeys.deviceId, value: deviceId);
      }
    }

    return DeviceData(
      deviceName: currentData.deviceName,
      deviceType: currentData.deviceType,
      deviceId: deviceId,
    );
  }

  static Future<DeviceData> _buildCurrentDeviceData() async {
    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        final androidId = await _androidIdPlugin.getId();
        return DeviceData(
          deviceName: info.model,
          deviceType: 'android',
          deviceId: androidId ?? '',
        );
      }
      if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        return DeviceData(
          deviceName: info.name,
          deviceType: 'ios',
          deviceId: '',
        );
      }
    } catch (_) {
      // Fallback below.
    }
    return DeviceData(
      deviceName: 'unknown',
      deviceType: Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'unknown'),
      deviceId: '',
    );
  }

  static Future<void> clearDeviceId() async {
    await _storage.delete(key: StorageKeys.deviceId);
  }
}