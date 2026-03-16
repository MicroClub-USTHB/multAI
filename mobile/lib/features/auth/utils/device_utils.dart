import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
 
class DeviceData {
  final String deviceName;
  final String deviceType;
  final String deviceId;
  final String fingerprint;
 
  const DeviceData({
    required this.deviceName,
    required this.deviceType,
    required this.deviceId,
    required this.fingerprint,
  });
}
 
class DeviceUtils {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();
 
  static Future<DeviceData> getDeviceData() async {
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
 
      final fingerprint = _generateFingerprint([
        info.id,
        info.model,
        info.brand,
        info.device,
        info.hardware,
        info.version.sdkInt.toString(),
      ]);
 
      return DeviceData(
        deviceName:  info.model,
        deviceType:  'android',
        deviceId:    info.id,
        fingerprint: fingerprint,
      );
    }
 
    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
 
      final fingerprint = _generateFingerprint([
        info.identifierForVendor ?? '',
        info.model,
        info.name,
        info.systemName,
        info.systemVersion,
      ]);
 
      return DeviceData(
        deviceName:  info.name,
        deviceType:  'ios',
        deviceId:    info.identifierForVendor ?? 'unknown',
        fingerprint: fingerprint,
      );
    }
 
    return DeviceData(
      deviceName:  'unknown',
      deviceType:  'unknown',
      deviceId:    'unknown',
      fingerprint: _generateFingerprint(['unknown']),
    );
  }
 
  static String _generateFingerprint(List<String> fields) {
    final raw    = fields.join('|');
    final bytes  = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
 