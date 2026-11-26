import 'package:flutter/material.dart';

import '../constants/storage_keys.dart';
import '../storage/app_local_storage.dart';

class LanguageService {
  final AppLocalStorage _storage;

  LanguageService(this._storage);

  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  Future<void> load() async {
    final savedLanguage = _storage.getString(StorageKeys.language);

    switch (savedLanguage) {
      case 'fr':
        locale.value = const Locale('fr');
        break;

      case 'ar':
        locale.value = const Locale('ar');
        break;

      case 'en':
      default:
        locale.value = const Locale('en');
        break;
    }
  }

  Future<void> setLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);

    locale.value = newLocale;

    await _storage.setString(StorageKeys.language, languageCode);
  }

  void dispose() {
    locale.dispose();
  }
}
