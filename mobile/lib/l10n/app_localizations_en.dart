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

  @override
  String get home => 'HOME';

  @override
  String get gallery => 'GALLERY';

  @override
  String get event => 'EVENT';

  @override
  String get account => 'ACCOUNT';

  @override
  String get eventsTitle => 'MultiAi Events';

  @override
  String get eventJoinedSuccess => 'Successfully joined event!';

  @override
  String get cachedDataMessage =>
      'Showing cached data. Connect to the internet to see the latest.';

  @override
  String get joinNewEvent => 'Join New Event';

  @override
  String get joinEventDescription =>
      'Have an invite? Enter the event code below to participate.';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get joinEvent => 'Join Event';

  @override
  String get activeEvents => 'Active Events';

  @override
  String ongoingEvents(Object count) {
    return '$count Ongoing';
  }

  @override
  String get noActiveEvents => 'No active events';

  @override
  String get joinEventToSeeHere => 'Join an event to see it here!';

  @override
  String get archivedEvents => 'Archived Events';

  @override
  String get noArchivedEvents => 'No archived events';

  @override
  String get archivedEventsEmpty => 'Your archived events will appear here.';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get allPhotos => 'All';

  @override
  String get soloPhotos => 'Solo';

  @override
  String get groupPhotos => 'Group';

  @override
  String get noPhotosYet => 'No photos yet';

  @override
  String get yourEvents => 'Your Events';

  @override
  String get scanEventQrCode => 'Scan Event QR Code';

  @override
  String get camera => 'Camera';

  @override
  String get galleryPicker => 'Gallery';

  @override
  String get previous => 'Previous';

  @override
  String get retry => 'Retry';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get pointCameraAtQrCode => 'Point your camera at the event QR code';

  @override
  String get skipOptionalPhotos => 'Skip optional photos';

  @override
  String get skip => 'Skip';

  @override
  String get completeEnrollment => 'Complete enrollment';

  @override
  String get uploadRequiredPhotosFirst => 'Upload required photos first';

  @override
  String get nextStep => 'Next step';

  @override
  String get complete => 'Complete';

  @override
  String get uploadRequired => 'Upload Required';

  @override
  String get next => 'Next';

  @override
  String get securityAlert => 'Security Alert';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkConnectionAndRetry =>
      'Please check your connection and try again.';

  @override
  String get previousStep => 'Previous step';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get appearance => 'Appearance';

  @override
  String get lightDarkMode => 'Light / Dark mode';

  @override
  String get language => 'Language';

  @override
  String get changeAppLanguage => 'Change app language';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageAlertsAndActivity => 'Manage alerts and activity';

  @override
  String get backupPhotos => 'Backup Photos';

  @override
  String get downloadPhotosAsZip => 'Download all photos as a ZIP file';

  @override
  String get myAlbums => 'My Albums';

  @override
  String get organizePhotosIntoAlbums => 'Organize photos into albums';

  @override
  String get mcMember => 'mc-member';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get photoUpdateFailed =>
      'Couldn\'t update your photo. Please try again.';
}
