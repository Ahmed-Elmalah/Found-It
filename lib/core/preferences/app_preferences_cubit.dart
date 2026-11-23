import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/constants/storage_keys.dart';

class AppPreferencesState extends Equatable {
  const AppPreferencesState({required this.themeMode, this.locale});

  final ThemeMode themeMode;

  /// Null means follow phone/system language.
  final Locale? locale;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit(this._prefs, {this.onLocaleChanged})
    : super(
        AppPreferencesState(
          themeMode: _loadThemeMode(_prefs),
          locale: _loadLocale(_prefs),
        ),
      );

  final SharedPreferences _prefs;

  /// Best-effort side effect after a language change (push token language).
  final Future<void> Function(Locale? locale)? onLocaleChanged;

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

  static Locale? _loadLocale(SharedPreferences prefs) {
    final code = prefs.getString(StorageKeys.languageCode);
    if (code == 'en') return const Locale('en');
    if (code == 'ar') return const Locale('ar');
    return null; // System / phone default
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

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(StorageKeys.languageCode);
    } else {
      await _prefs.setString(StorageKeys.languageCode, locale.languageCode);
    }
    emit(state.copyWith(locale: () => locale));
    await _notifyLocaleChanged(locale);
  }

  /// Push text is rendered in the language saved with the device token
  /// (Section 8), so a language change re-saves it — never blocking the UI.
  Future<void> _notifyLocaleChanged(Locale? locale) async {
    final onLocaleChanged = this.onLocaleChanged;
    if (onLocaleChanged == null) return;
    try {
      await onLocaleChanged(locale);
    } catch (error) {
      debugPrint('[AppPreferencesCubit] locale side effect failed: $error');
    }
  }
}
