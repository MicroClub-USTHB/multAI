import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

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

  static Future<DeviceData> getDeviceData() async {
    try {
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;

        final deviceFingerprint = _generateFingerprint([
          info.id,
          info.hardware,
          info.brand,
          info.device,
        ]);

        return DeviceData(
          deviceName:        info.model,
          platform:          'android',
          deviceId:          info.id,
          deviceFingerprint: deviceFingerprint,
        );
      }

      if (Platform.isIOS) {
        final info = await _plugin.iosInfo;

        final deviceFingerprint = _generateFingerprint([
          info.identifierForVendor ?? '',
          info.model,
          info.name,
        ]);

        return DeviceData(
          deviceName:        info.name,
          platform:          'ios',
          deviceId:          info.identifierForVendor ?? 'unknown',
          deviceFingerprint: deviceFingerprint,
        );
      }
    } catch (_) {
      // device_info_plus failed — return safe fallback
      return DeviceData(
        deviceName:        'unknown',
        platform:          Platform.isAndroid ? 'android' : 'ios',
        deviceId:          'unknown',
        deviceFingerprint: _generateFingerprint(['unknown']),
      );
    }

    // unknown platform fallback
    return DeviceData(
      deviceName:        'unknown',
      platform:          'unknown',
      deviceId:          'unknown',
      deviceFingerprint: _generateFingerprint(['unknown']),
    );
  }

  static String _generateFingerprint(List<String> fields) {
    final raw    = fields.join('|');
    final bytes  = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
