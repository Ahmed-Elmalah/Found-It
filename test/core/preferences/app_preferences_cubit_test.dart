import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/constants/storage_keys.dart';
import 'package:found_it/core/preferences/app_preferences_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesCubit', () {
    test('default state uses system theme and null locale (system default)', () {
      SharedPreferences.setMockInitialValues({});
      final prefs = SharedPreferences.getInstance();

      return prefs.then((p) {
        final cubit = AppPreferencesCubit(p);
        expect(cubit.state.themeMode, ThemeMode.system);
        expect(cubit.state.locale, isNull);
      });
    });

    test('loads saved dark theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.themeMode: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppPreferencesCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.dark);
    });

    test('loads saved light theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.themeMode: 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppPreferencesCubit(prefs);

      expect(cubit.state.themeMode, ThemeMode.light);
    });

    test('loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        StorageKeys.languageCode: 'en',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppPreferencesCubit(prefs);

      expect(cubit.state.locale, const Locale('en'));
    });

    test('setThemeMode updates state and persists in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppPreferencesCubit(prefs);

      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(prefs.getString(StorageKeys.themeMode), 'dark');

      await cubit.setThemeMode(ThemeMode.light);
      expect(cubit.state.themeMode, ThemeMode.light);
      expect(prefs.getString(StorageKeys.themeMode), 'light');

      await cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state.themeMode, ThemeMode.system);
      expect(prefs.getString(StorageKeys.themeMode), 'system');
    });

    test('setLocale updates state and persists in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppPreferencesCubit(prefs);

      await cubit.setLocale(const Locale('ar'));
      expect(cubit.state.locale, const Locale('ar'));
      expect(prefs.getString(StorageKeys.languageCode), 'ar');

      await cubit.setLocale(const Locale('en'));
      expect(cubit.state.locale, const Locale('en'));
      expect(prefs.getString(StorageKeys.languageCode), 'en');

      // Setting null reverts to system and removes the key
      await cubit.setLocale(null);
      expect(cubit.state.locale, isNull);
      expect(prefs.containsKey(StorageKeys.languageCode), isFalse);
    });
  });
}
