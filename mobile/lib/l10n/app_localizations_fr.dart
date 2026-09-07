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
}
