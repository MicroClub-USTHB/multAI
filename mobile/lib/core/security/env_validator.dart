import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    return Uri.tryParse(url)?.hasScheme == true &&
        Uri.tryParse(url)?.host.isNotEmpty == true;
  }

  static bool isProduction() {
    final url = dotenv.env['BASE_URL']?.trim() ?? '';
    return url.startsWith('https://');
  }
}
