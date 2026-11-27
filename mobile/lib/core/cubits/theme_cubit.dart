import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';

const _themeKey = 'theme_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  final AppLocalStorage _localStorage;

  ThemeCubit(this._localStorage) : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _localStorage.getString(_themeKey);
    if (saved == 'light') {
      emit(ThemeMode.light);
    } else if (saved == 'system') {
      emit(ThemeMode.system);
    } else {
      emit(ThemeMode.dark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _localStorage.setString(_themeKey, mode.name);
    emit(mode);
  }

  void toggleTheme() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(next);
  }
}
