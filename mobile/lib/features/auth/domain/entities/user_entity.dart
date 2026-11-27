import 'device_entity.dart';
import 'session_entity.dart';

class UserEntity {
  final String id;
  final String email;
  final List<DeviceEntity> devices;
  final SessionEntity? session;
  final bool isOnboarded;

  const UserEntity({
    required this.id,
    required this.email,
    required this.devices,
    this.session,
    this.isOnboarded = false,
  });
}

typedef MeEntity = UserEntity;
