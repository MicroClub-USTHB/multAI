import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'secure_logger.dart';

class EnvValidator {
  EnvValidator._();

  static const List<String> _requiredKeys = [
    'BASE_URL',
    'GOOGLE_CLIENT_ID',
  ];

  static List<String> validate() {
    final missing = <String>[];
    for (final key in _requiredKeys) {
      final value = dotenv.env[key]?.trim();
      if (value == null || value.isEmpty) {
        missing.add(key);
      }
    }
    return missing;
  }

  static bool isBaseUrlValid() {
    final url = dotenv.env['BASE_URL']?.trim() ?? '';
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri?.hasScheme == true && uri?.host.isNotEmpty == true;
  }

  static bool isProduction() {
    final url = dotenv.env['BASE_URL']?.trim() ?? '';
    return url.startsWith('https://');
  }

  static bool isBaseUrlHttps() {
    final url = dotenv.env['BASE_URL']?.trim() ?? '';
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  static void validateProduction() {
    if (!isBaseUrlHttps()) {
      SecureLogger.error(
        'EnvValidator',
        'PRODUCTION MODE REQUIRES HTTPS. Current BASE_URL is not HTTPS.',
      );
    }

    final missing = validate();
    if (missing.isNotEmpty) {
      SecureLogger.error(
        'EnvValidator',
        'Missing required environment variables: $missing',
      );
    }

    final url = dotenv.env['BASE_URL']?.trim() ?? '';
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host == '192.168.100.2') {
      SecureLogger.warning(
        'EnvValidator',
        'Using local development URL. Not suitable for production.',
      );
    }
  }
}
