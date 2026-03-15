import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';


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

class DeviceInfoService {
  final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  Future<DeviceData> getDeviceData() async {
    if (Platform.isAndroid) {
        final info  = await _plugin.androidInfo;
        return  DeviceData(
          deviceName: info.model,
          deviceType: 'android',
          deviceId: info.id ,
        );
    }
    if(Platform.isIOS){
      final info = await _plugin.iosInfo;
      return DeviceData(
      deviceName: info.name, 
      deviceType: 'ios', 
      deviceId: info.identifierForVendor ?? 'unknown');
    }

    return const DeviceData(
      deviceName: 'unknown',
      deviceType: 'unknown',
      deviceId: 'unknown',
    );
  }
}