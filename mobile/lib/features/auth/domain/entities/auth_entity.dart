class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final String userId;
  final bool isNewUser;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    required this.userId,
    this.isNewUser = false,
  });
}
