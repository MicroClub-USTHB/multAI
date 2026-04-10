import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/auth/register-login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // ── Face Enrollment ────────────────────────────────────────────────────────
  static const String faceEnrollment = '/face-enrollment/upload';
  //── account ─────────────────────────────────────────────────────────────────
  static const String account = '/account';
  static const String revokeDevice = '/auth/devices';

  // ── NotificationsNotifications ──────────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';
  static const String registerPushToken = '/notifications/push-token/register';
  static const String revokePushToken = '/notifications/push-token/revoke';
  // ── Photo Approval ─────────────────────────────────────────────────────────
  static const String photoApprovals = '/photos/approvals';
  static const String photoDecision = '/photos';
}
