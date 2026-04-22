import '../../../../core/extensions/string_extensions.dart';

class EventCodeValidator {
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an event code';
    }
    final code = value.toEventCode();
    if (code.isEmpty) {
      return 'Invalid event code';
    }
    return null;
  }
}
