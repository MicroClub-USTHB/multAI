import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';

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
  static final Uuid _uuid = Uuid();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<DeviceData> getDeviceData() async {
    // TEST OVERRIDE: set via --dart-define flags (remove when done testing)
    const testDeviceId = String.fromEnvironment('TEST_DEVICE_ID');
    const testDeviceName = String.fromEnvironment('TEST_DEVICE_NAME');
    const testDeviceType = String.fromEnvironment('TEST_DEVICE_TYPE');
    if (testDeviceId.isNotEmpty && testDeviceName.isNotEmpty && testDeviceType.isNotEmpty) {
      return DeviceData(
        deviceName: testDeviceName,
        deviceType: testDeviceType,
        deviceId: testDeviceId,
      );
    }

    final storedDeviceId = await _storage.read(key: StorageKeys.deviceId);

    final currentData = await _buildCurrentDeviceData();
    final deviceId = storedDeviceId?.trim().isNotEmpty == true
        ? storedDeviceId!.trim()
        : _uuid.v4();

    if (storedDeviceId == null || storedDeviceId.trim().isEmpty) {
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);
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
        return DeviceData(
          deviceName: info.model,
          deviceType: 'android',
          deviceId: '',
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
