abstract class InputSanitizer {
  InputSanitizer._();

  static String sanitize(String? input) {
    if (input == null) return '';
    return input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('&', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .trim();
  }

  static String sanitizeEmail(String? input) {
    if (input == null) return '';
    return input.trim().toLowerCase();
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
}
