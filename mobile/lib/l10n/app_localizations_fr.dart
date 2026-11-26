// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get theme => 'Thème';

  @override
  String get languages => 'Langues';

  @override
  String get chooseYourLanguage => 'Choisissez votre langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get editName => 'Modifier le nom';

  @override
  String get yourName => 'Votre nom';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get clearImageCache => 'Vider le cache des images';

  @override
  String get clearImageCacheDescription =>
      'Cela supprimera toutes les photos mises en cache de votre appareil. Les images devront être téléchargées à nouveau lorsqu\'elles seront consultées.';

  @override
  String get clear => 'Vider';

  @override
  String get freeUpStorage => 'Libérer de l\'espace de stockage';

  @override
  String get clearingCache => 'Nettoyage du cache...';

  @override
  String freedStorage(Object storage, Object files) {
    return '$storage libérés ($files fichiers)';
  }

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get systemDefault => 'Par défaut du système';

  @override
  String get chooseTheme => 'Choisissez un thème clair ou sombre';

  @override
  String get accountSettings => 'PARAMÈTRES DU COMPTE';

  @override
  String get privacySecurity => 'Confidentialité et sécurité';

  @override
  String get privacySecurityDescription =>
      'Mot de passe, 2FA et partage des données';

  @override
  String get support => 'ASSISTANCE';

  @override
  String get helpCenter => 'Centre d\'aide';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Êtes-vous sûr de vouloir supprimer ce compte ? Cette action est irréversible.';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get home => 'ACCUEIL';

  @override
  String get gallery => 'GALERIE';

  @override
  String get event => 'ÉVÉNEMENT';

  @override
  String get account => 'COMPTE';

  @override
  String get eventsTitle => 'Événements MultiAi';

  @override
  String get eventJoinedSuccess => 'Événement rejoint avec succès !';

  @override
  String get cachedDataMessage =>
      'Affichage des données en cache. Connectez-vous à Internet pour voir les dernières données.';

  @override
  String get joinNewEvent => 'Rejoindre un nouvel événement';

  @override
  String get joinEventDescription =>
      'Vous avez une invitation ? Entrez le code de l\'événement ci-dessous pour participer.';

  @override
  String get scanQrCode => 'Scanner le code QR';

  @override
  String get joinEvent => 'Rejoindre l\'événement';

  @override
  String get activeEvents => 'Événements actifs';

  @override
  String ongoingEvents(Object count) {
    return '$count en cours';
  }

  @override
  String get noActiveEvents => 'Aucun événement actif';

  @override
  String get joinEventToSeeHere => 'Rejoignez un événement pour le voir ici !';

  @override
  String get archivedEvents => 'Événements archivés';

  @override
  String get noArchivedEvents => 'Aucun événement archivé';

  @override
  String get archivedEventsEmpty => 'Vos événements archivés apparaîtront ici.';

  @override
  String get galleryTitle => 'Galerie';

  @override
  String get allPhotos => 'Toutes';

  @override
  String get soloPhotos => 'Solo';

  @override
  String get groupPhotos => 'Groupe';

  @override
  String get noPhotosYet => 'Pas encore de photos';

  @override
  String get yourEvents => 'Vos événements';

  @override
  String get scanEventQrCode => 'Scanner le code QR de l\'événement';

  @override
  String get camera => 'Caméra';

  @override
  String get galleryPicker => 'Galerie';

  @override
  String get previous => 'Précédent';

  @override
  String get retry => 'Réessayer';

  @override
  String get noEventsYet => 'Pas encore d’événements';

  @override
  String get pointCameraAtQrCode =>
      'Pointez votre caméra vers le code QR de l’événement';

  @override
  String get skipOptionalPhotos => 'Ignorer les photos facultatives';

  @override
  String get skip => 'Ignorer';

  @override
  String get completeEnrollment => 'Terminer l’enregistrement';

  @override
  String get uploadRequiredPhotosFirst =>
      'Importez d’abord les photos requises';

  @override
  String get nextStep => 'Étape suivante';

  @override
  String get complete => 'Terminer';

  @override
  String get uploadRequired => 'Importation requise';

  @override
  String get next => 'Suivant';

  @override
  String get securityAlert => 'Alerte de sécurité';

  @override
  String get noInternetConnection => 'Aucune connexion Internet';

  @override
  String get checkConnectionAndRetry =>
      'Veuillez vérifier votre connexion et réessayer.';

  @override
  String get previousStep => 'Étape précédente';

  @override
  String get preferences => 'PRÉFÉRENCES';

  @override
  String get appearance => 'Apparence';

  @override
  String get lightDarkMode => 'Mode clair / sombre';

  @override
  String get language => 'Langue';

  @override
  String get changeAppLanguage => 'Changer la langue de l\'application';

  @override
  String get selectTheme => 'Sélectionner le thème';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageAlertsAndActivity => 'Gérer les alertes et l\'activité';

  @override
  String get backupPhotos => 'Sauvegarder les photos';

  @override
  String get downloadPhotosAsZip =>
      'Télécharger toutes les photos en fichier ZIP';

  @override
  String get myAlbums => 'Mes albums';

  @override
  String get organizePhotosIntoAlbums => 'Organiser les photos en albums';

  @override
  String get mcMember => 'membre mc';

  @override
  String get changeProfilePhoto => 'Changer la photo de profil';

  @override
  String get photoUpdateFailed =>
      'Impossible de mettre à jour votre photo. Réessayez.';
}
