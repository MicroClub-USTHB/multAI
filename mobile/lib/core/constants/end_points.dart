import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String baseUrl =
      dotenv.env['BASE_URL'] ?? '';

  static const String login = '/auth/register-login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
}
