class AppValidators {
  static final RegExp _emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static String? validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (!_passwordRegex.hasMatch(v)) {
      return 'Password must be at least 8 characters and include letters and numbers';
    }

    return null;
  }
}
