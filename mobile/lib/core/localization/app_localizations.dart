import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'ar':
        return _ar;
      case 'fr':
        return _fr;
      default:
        return _en;
    }
  }

  String translate(String key) => _strings[key] ?? key;

  // ── English ──────────────────────────────────────────────────────────────────
  static const Map<String, String> _en = {
    'ACCOUNT SETTINGS': 'ACCOUNT SETTINGS',
    'Notifications': 'Notifications',
    'Manage alerts and activity': 'Manage alerts and activity',
    'Privacy & Security': 'Privacy & Security',
    'Password, 2FA, and data sharing': 'Password, 2FA, and data sharing',
    'Account Data': 'Account Data',
    'Export or manage your personal data': 'Export or manage your personal data',
    'Clear Image Cache': 'Clear Image Cache',
    'Free up storage space': 'Free up storage space',
    'SUPPORT': 'SUPPORT',
    'Help Center': 'Help Center',
    'Appearance': 'Appearance',
    'Light / Dark mode': 'Light / Dark mode',
    'Language': 'Language',
    'Change app language': 'Change app language',
    'Cancel': 'Cancel',
    'Save': 'Save',
    'Clear': 'Clear',
    'Edit Name': 'Edit Name',
    'Your name': 'Your name',
    'Clearing cache...': 'Clearing cache...',
    'PREFERENCES': 'PREFERENCES',
    'Dark': 'Dark',
    'Light': 'Light',
    'System': 'System',
    'English': 'English',
    'Arabic': 'Arabic',
    'French': 'French',
    'Select theme': 'Select theme',
    'Select language': 'Select language',
    'mc-member': 'mc-member',
    'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.':
        'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.',
    'Backup Photos': 'Backup Photos',
    'Download all photos as a ZIP file': 'Download all photos as a ZIP file',
    'My Albums': 'My Albums',
    'Organize photos into albums': 'Organize photos into albums',
  };

  // ── Arabic ───────────────────────────────────────────────────────────────────
  static const Map<String, String> _ar = {
    'ACCOUNT SETTINGS': 'إعدادات الحساب',
    'Notifications': 'الإشعارات',
    'Manage alerts and activity': 'إدارة التنبيهات والنشاط',
    'Privacy & Security': 'الخصوصية والأمان',
    'Password, 2FA, and data sharing': 'كلمة المرور والمصادقة الثنائية ومشاركة البيانات',
    'Account Data': 'بيانات الحساب',
    'Export or manage your personal data': 'تصدير أو إدارة بياناتك الشخصية',
    'Clear Image Cache': 'مسح ذاكرة الصور المؤقتة',
    'Free up storage space': 'تحرير مساحة التخزين',
    'SUPPORT': 'الدعم',
    'Help Center': 'مركز المساعدة',
    'Appearance': 'المظهر',
    'Light / Dark mode': 'الوضع الفاتح / الداكن',
    'Language': 'اللغة',
    'Change app language': 'تغيير لغة التطبيق',
    'Cancel': 'إلغاء',
    'Save': 'حفظ',
    'Clear': 'مسح',
    'Edit Name': 'تعديل الاسم',
    'Your name': 'اسمك',
    'Clearing cache...': 'جاري مسح ذاكرة التخزين المؤقت...',
    'PREFERENCES': 'التفضيلات',
    'Dark': 'داكن',
    'Light': 'فاتح',
    'System': 'النظام',
    'English': 'الإنجليزية',
    'Arabic': 'العربية',
    'French': 'الفرنسية',
    'Select theme': 'اختر المظهر',
    'Select language': 'اختر اللغة',
    'mc-member': 'عضو',
    'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.':
        'سيؤدي هذا إلى إزالة جميع الصور المخزنة مؤقتاً من جهازك. سيتم إعادة تحميل الصور عند عرضها مرة أخرى.',
    'Backup Photos': 'النسخ الاحتياطي للصور',
    'Download all photos as a ZIP file': 'تحميل جميع الصور كملف مضغوط',
    'My Albums': 'ألبوماتي',
    'Organize photos into albums': 'تنظيم الصور في ألبومات',
  };

  // ── French ───────────────────────────────────────────────────────────────────
  static const Map<String, String> _fr = {
    'ACCOUNT SETTINGS': 'PARAMÈTRES DU COMPTE',
    'Notifications': 'Notifications',
    'Manage alerts and activity': 'Gérer les alertes et l\'activité',
    'Privacy & Security': 'Confidentialité et sécurité',
    'Password, 2FA, and data sharing': 'Mot de passe, 2FA et partage de données',
    'Account Data': 'Données du compte',
    'Export or manage your personal data': 'Exporter ou gérer vos données personnelles',
    'Clear Image Cache': 'Vider le cache des images',
    'Free up storage space': 'Libérer de l\'espace de stockage',
    'SUPPORT': 'SUPPORT',
    'Help Center': 'Centre d\'aide',
    'Appearance': 'Apparence',
    'Light / Dark mode': 'Mode clair / sombre',
    'Language': 'Langue',
    'Change app language': 'Changer la langue de l\'application',
    'Cancel': 'Annuler',
    'Save': 'Enregistrer',
    'Clear': 'Vider',
    'Edit Name': 'Modifier le nom',
    'Your name': 'Votre nom',
    'Clearing cache...': 'Nettoyage du cache...',
    'PREFERENCES': 'PRÉFÉRENCES',
    'Dark': 'Sombre',
    'Light': 'Clair',
    'System': 'Système',
    'English': 'Anglais',
    'Arabic': 'Arabe',
    'French': 'Français',
    'Select theme': 'Sélectionner le thème',
    'Select language': 'Sélectionner la langue',
    'mc-member': 'membre',
    'This will remove all cached photos from your device. Images will need to be re-downloaded when viewed again.':
        'Cela supprimera toutes les photos en cache de votre appareil. Les images devront être re-téléchargées lors de la prochaine visualisation.',
    'Backup Photos': 'Sauvegarde des photos',
    'Download all photos as a ZIP file': 'Télécharger toutes les photos en fichier ZIP',
    'My Albums': 'Mes albums',
    'Organize photos into albums': 'Organiser les photos en albums',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
