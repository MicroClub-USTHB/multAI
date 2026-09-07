import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @clearImageCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Image Cache'**
  String get clearImageCache;

  /// No description provided for @clearImageCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.'**
  String get clearImageCacheDescription;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @freeUpStorage.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get freeUpStorage;

  /// No description provided for @clearingCache.
  ///
  /// In en, this message translates to:
  /// **'Clearing cache...'**
  String get clearingCache;

  /// No description provided for @freedStorage.
  ///
  /// In en, this message translates to:
  /// **'Freed {storage} ({files} files)'**
  String freedStorage(Object storage, Object files);

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose dark or light theme'**
  String get chooseTheme;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get accountSettings;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Password, 2FA, and data sharing'**
  String get privacySecurityDescription;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get home;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'GALLERY'**
  String get gallery;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'EVENT'**
  String get event;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'MultiAi Events'**
  String get eventsTitle;

  /// No description provided for @eventJoinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully joined event!'**
  String get eventJoinedSuccess;

  /// No description provided for @cachedDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Showing cached data. Connect to the internet to see the latest.'**
  String get cachedDataMessage;

  /// No description provided for @joinNewEvent.
  ///
  /// In en, this message translates to:
  /// **'Join New Event'**
  String get joinNewEvent;

  /// No description provided for @joinEventDescription.
  ///
  /// In en, this message translates to:
  /// **'Have an invite? Enter the event code below to participate.'**
  String get joinEventDescription;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCode;

  /// No description provided for @joinEvent.
  ///
  /// In en, this message translates to:
  /// **'Join Event'**
  String get joinEvent;

  /// No description provided for @activeEvents.
  ///
  /// In en, this message translates to:
  /// **'Active Events'**
  String get activeEvents;

  /// No description provided for @ongoingEvents.
  ///
  /// In en, this message translates to:
  /// **'{count} Ongoing'**
  String ongoingEvents(Object count);

  /// No description provided for @noActiveEvents.
  ///
  /// In en, this message translates to:
  /// **'No active events'**
  String get noActiveEvents;

  /// No description provided for @joinEventToSeeHere.
  ///
  /// In en, this message translates to:
  /// **'Join an event to see it here!'**
  String get joinEventToSeeHere;

  /// No description provided for @archivedEvents.
  ///
  /// In en, this message translates to:
  /// **'Archived Events'**
  String get archivedEvents;

  /// No description provided for @noArchivedEvents.
  ///
  /// In en, this message translates to:
  /// **'No archived events'**
  String get noArchivedEvents;

  /// No description provided for @archivedEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your archived events will appear here.'**
  String get archivedEventsEmpty;

  /// No description provided for @galleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryTitle;

  /// No description provided for @allPhotos.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPhotos;

  /// No description provided for @soloPhotos.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get soloPhotos;

  /// No description provided for @groupPhotos.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupPhotos;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @yourEvents.
  ///
  /// In en, this message translates to:
  /// **'Your Events'**
  String get yourEvents;

  /// No description provided for @scanEventQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan Event QR Code'**
  String get scanEventQrCode;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @galleryPicker.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryPicker;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @pointCameraAtQrCode.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the event QR code'**
  String get pointCameraAtQrCode;

  /// No description provided for @skipOptionalPhotos.
  ///
  /// In en, this message translates to:
  /// **'Skip optional photos'**
  String get skipOptionalPhotos;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @completeEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Complete enrollment'**
  String get completeEnrollment;

  /// No description provided for @uploadRequiredPhotosFirst.
  ///
  /// In en, this message translates to:
  /// **'Upload required photos first'**
  String get uploadRequiredPhotosFirst;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get nextStep;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @uploadRequired.
  ///
  /// In en, this message translates to:
  /// **'Upload Required'**
  String get uploadRequired;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @securityAlert.
  ///
  /// In en, this message translates to:
  /// **'Security Alert'**
  String get securityAlert;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// No description provided for @checkConnectionAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get checkConnectionAndRetry;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous step'**
  String get previousStep;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @lightDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Light / Dark mode'**
  String get lightDarkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageAlertsAndActivity.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts and activity'**
  String get manageAlertsAndActivity;

  /// No description provided for @backupPhotos.
  ///
  /// In en, this message translates to:
  /// **'Backup Photos'**
  String get backupPhotos;

  /// No description provided for @downloadPhotosAsZip.
  ///
  /// In en, this message translates to:
  /// **'Download all photos as a ZIP file'**
  String get downloadPhotosAsZip;

  /// No description provided for @myAlbums.
  ///
  /// In en, this message translates to:
  /// **'My Albums'**
  String get myAlbums;

  /// No description provided for @organizePhotosIntoAlbums.
  ///
  /// In en, this message translates to:
  /// **'Organize photos into albums'**
  String get organizePhotosIntoAlbums;

  /// No description provided for @mcMember.
  ///
  /// In en, this message translates to:
  /// **'mc-member'**
  String get mcMember;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
