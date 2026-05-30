import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String get baseUrl => dotenv.env['BASE_URL']?.trim() ?? '';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String registerLogin = '/auth/register-login';
  static const String login = registerLogin;
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String account = me;
  static const String revokeDevice = '/auth/revoke-device';
  static const String updateDeviceToken = '/auth/devices/token';
  static const String inactivateDevice = '/auth/devices/inactivate';

  // ── Face Enrollment ────────────────────────────────────────────────────────
  static const String faceEnrollment = '/user/enroll';

  // ── Events  ────────────────────────────────────────────────────────────────
  static const String userEvents = '/user/event/me';
  static const String joinEvent = '/user/event/join';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications = '/user/notifications';
  static const String notificationsRead = '/user/notifications/read';

  // ── Photo Approval ─────────────────────────────────────────────────────────
  static const String photoApprovals = '/user/photos/approvals';
  static const String photoDecision = '/user/photos';

  // ── Gallery ────────────────────────────────────────────────────────────────
  static const String photos = '/user/photos';
}
