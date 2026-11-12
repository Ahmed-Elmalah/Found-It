import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/constants/storage_keys.dart';

class AppPreferencesState extends Equatable {
  const AppPreferencesState({
    required this.themeMode,
    required this.locale,
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit(this._prefs)
      : super(AppPreferencesState(
          themeMode: _loadThemeMode(_prefs),
          locale: _loadLocale(_prefs),
        ));

  final SharedPreferences _prefs;

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final saved = prefs.getString(StorageKeys.themeMode);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Locale _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(StorageKeys.languageCode);
    if (code == 'en') return const Locale('en');
    if (code == 'ar') return const Locale('ar');
    return const Locale('ar'); // Default to Arabic as primary locale
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(StorageKeys.languageCode, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
