import 'package:shared_preferences/shared_preferences.dart';

import 'settings_storage.dart';

class SharedPreferencesStorage implements SettingsStorage {
  static const _keyPrefix = 'dgis_navigation.';

  final SharedPreferences _prefs;

  SharedPreferencesStorage(this._prefs);

  String _k(String key) => '$_keyPrefix$key';

  @override
  bool getBool(String key, {required bool defaultValue}) =>
      _prefs.getBool(_k(key)) ?? defaultValue;

  @override
  Future<bool> putBool(String key, {required bool value}) =>
      _prefs.setBool(_k(key), value);

  @override
  int getInt(String key, int defaultValue) =>
      _prefs.getInt(_k(key)) ?? defaultValue;

  @override
  Future<bool> putInt(String key, int value) => _prefs.setInt(_k(key), value);

  @override
  double getDouble(String key, double defaultValue) =>
      _prefs.getDouble(_k(key)) ?? defaultValue;

  @override
  Future<bool> putDouble(String key, double value) =>
      _prefs.setDouble(_k(key), value);

  @override
  String getString(String key, String defaultValue) =>
      _prefs.getString(_k(key)) ?? defaultValue;

  @override
  Future<bool> putString(String key, String value) =>
      _prefs.setString(_k(key), value);
}
