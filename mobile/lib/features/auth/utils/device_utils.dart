import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceData {
  final String deviceName;
  final String platform;
  final String deviceId;
  final String deviceFingerprint;

  const DeviceData({
    required this.deviceName,
    required this.platform,
    required this.deviceId,
    required this.deviceFingerprint,
  });
}

class DeviceUtils {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();
  static const _storage = FlutterSecureStorage();
  static const String _fingerprintKey = 'secure_device_fingerprint';

  static Future<DeviceData> getDeviceData() async {
    String? storedFingerprint = await _storage.read(key: _fingerprintKey);

    DeviceData currentData;

    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        currentData = _buildAndroidData(info);
      } else if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        currentData = _buildIOSData(info);
      } else {
        currentData = _buildFallbackData();
      }
    } catch (_) {
      currentData = _buildFallbackData();
    }

    if (storedFingerprint != null) {
      return DeviceData(
        deviceName: currentData.deviceName,
        platform: currentData.platform,
        deviceId: currentData.deviceId,
        deviceFingerprint: storedFingerprint,
      );
    }

    await _storage.write(
      key: _fingerprintKey,
      value: currentData.deviceFingerprint,
    );

    return currentData;
  }

  static DeviceData _buildAndroidData(AndroidDeviceInfo info) {
    final fingerprint = _generateFingerprint([
      info.id,
      info.hardware,
      info.brand,
      info.device,
    ]);

    return DeviceData(
      deviceName: info.model,
      platform: 'android',
      deviceId: info.id,
      deviceFingerprint: fingerprint,
    );
  }

  static DeviceData _buildIOSData(IosDeviceInfo info) {
    final fingerprint = _generateFingerprint([
      info.identifierForVendor ?? '',
      info.model,
      info.name,
    ]);

    return DeviceData(
      deviceName: info.name,
      platform: 'ios',
      deviceId: info.identifierForVendor ?? 'unknown',
      deviceFingerprint: fingerprint,
    );
  }

  static DeviceData _buildFallbackData() {
    return DeviceData(
      deviceName: 'unknown',
      platform: Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'unknown'),
      deviceId: 'unknown',
      deviceFingerprint: _generateFingerprint(['unknown']),
    );
  }

  static String _generateFingerprint(List<String> fields) {
    final raw = fields.join('|');
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
