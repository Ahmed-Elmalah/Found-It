import 'package:shared_preferences/shared_preferences.dart';

import 'package:found_it/core/constants/storage_keys.dart';

abstract interface class CityLocalDataSource {
  Future<void> saveSelectedCityId(String cityId);
  String? getSelectedCityId();
  Future<void> clearSelectedCityId();
}

class CityLocalDataSourceImpl implements CityLocalDataSource {
  const CityLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> saveSelectedCityId(String cityId) =>
      _prefs.setString(StorageKeys.selectedCity, cityId);

  @override
  String? getSelectedCityId() => _prefs.getString(StorageKeys.selectedCity);

  @override
  Future<void> clearSelectedCityId() => _prefs.remove(StorageKeys.selectedCity);
}
