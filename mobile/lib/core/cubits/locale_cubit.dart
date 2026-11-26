import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';

const _localeKey = 'app_locale';

class LocaleCubit extends Cubit<Locale> {
  final AppLocalStorage _localStorage;

  LocaleCubit(this._localStorage) : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final saved = _localStorage.getString(_localeKey);
    if (saved != null) {
      emit(Locale(saved));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _localStorage.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  bool get isRtl => state.languageCode == 'ar';
}
