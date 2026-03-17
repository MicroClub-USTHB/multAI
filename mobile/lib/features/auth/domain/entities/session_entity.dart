class SessionEntity {
  final String sessionId;
  final String deviceId;
  final DateTime lastActive;
  final DateTime expiresAt;
 
  const SessionEntity({
    required this.sessionId,
    required this.deviceId,
    required this.lastActive,
    required this.expiresAt,
  });
}
 