abstract class InputSanitizer {
  InputSanitizer._();

  static final _htmlTagRegExp = RegExp(r'<[^>]*>');
  static final _scriptRegExp = RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true);
  static final _sqlInjectionRegExp = RegExp(
    r"('|--|;|/\*|\\\\\*|exec|insert|select|delete|update|drop|alter|create|truncate|union|declare|or\s+1=1)",
    caseSensitive: false,
  );

  static String sanitize(String? input) {
    if (input == null) return '';
    return input
        .replaceAll(_scriptRegExp, '')
        .replaceAll(_htmlTagRegExp, '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('&', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('`', '')
        .replaceAll('\$', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .trim();
  }

  static String sanitizeEmail(String? input) {
    if (input == null) return '';
    final sanitized = input.replaceAll(RegExp(r'[^\w.@+-]'), '');
    return sanitized.trim().toLowerCase();
  }

  static String? validateEmail(String? input) {
    final email = sanitizeEmail(input);
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) return 'Invalid email format';
    return null;
  }

  static String? validatePassword(String? input) {
    if (input == null || input.isEmpty) return 'Password is required';
    if (input.length < 8) return 'Password must be at least 8 characters';
    if (!input.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!input.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!input.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!input.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }

  static bool hasSqlInjection(String? input) {
    if (input == null) return false;
    return _sqlInjectionRegExp.hasMatch(input);
  }

  static bool hasXssPatterns(String? input) {
    if (input == null) return false;
    return _htmlTagRegExp.hasMatch(input) || _scriptRegExp.hasMatch(input);
  }

  static String sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\w\-_\. ]'), '');
  }

  static String sanitizeUrl(String url) {
    final sanitized = url.trim();
    if (!sanitized.startsWith('https://') && !sanitized.startsWith('http://')) {
      return '';
    }
    return sanitized.replaceAll(
      RegExp(r"[^\w\-._~:/?#\[\]@!$&'()*+,;=]"),
      '',
    );
  }

  static bool isUrlSafe(String url) {
    final sanitized = sanitizeUrl(url);
    if (sanitized.isEmpty) return false;
    final uri = Uri.tryParse(sanitized);
    if (uri == null) return false;
    return uri.scheme == 'https' || uri.scheme == 'http';
  }
}
