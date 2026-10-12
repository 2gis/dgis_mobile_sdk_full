abstract class SettingsStorage {
  bool getBool(String key, {required bool defaultValue});
  Future<bool> putBool(String key, {required bool value});

  int getInt(String key, int defaultValue);
  Future<bool> putInt(String key, int value);

  double getDouble(String key, double defaultValue);
  Future<bool> putDouble(String key, double value);

  String getString(String key, String defaultValue);
  Future<bool> putString(String key, String value);
}
