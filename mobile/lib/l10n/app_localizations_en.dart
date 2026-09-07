// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get theme => 'Theme';

  @override
  String get languages => 'Languages';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String get editName => 'Edit Name';

  @override
  String get yourName => 'Your name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get clearImageCache => 'Clear Image Cache';

  @override
  String get clearImageCacheDescription =>
      'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.';

  @override
  String get clear => 'Clear';

  @override
  String get freeUpStorage => 'Free up storage space';

  @override
  String get clearingCache => 'Clearing cache...';

  @override
  String freedStorage(Object storage, Object files) {
    return 'Freed $storage ($files files)';
  }

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System default';

  @override
  String get chooseTheme => 'Choose dark or light theme';

  @override
  String get accountSettings => 'ACCOUNT SETTINGS';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecurityDescription => 'Password, 2FA, and data sharing';

  @override
  String get support => 'SUPPORT';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete this account? This action cannot be undone.';

  @override
  String get logout => 'Logout';
}
