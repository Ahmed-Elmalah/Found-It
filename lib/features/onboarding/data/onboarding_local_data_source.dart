import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/constants/storage_keys.dart';

abstract interface class OnboardingLocalDataSource {
  bool isFirstLaunch();
  Future<void> setOnboardingCompleted();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const OnboardingLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool isFirstLaunch() => _prefs.getBool(StorageKeys.isFirstLaunch) ?? true;

  @override
  Future<void> setOnboardingCompleted() =>
      _prefs.setBool(StorageKeys.isFirstLaunch, false);
}
