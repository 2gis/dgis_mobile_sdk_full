import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'settings_storage.dart';

const _sentinelNullInt = -2147483648;
const _sentinelNullString = '__NULL__';

@immutable
sealed class SettingsKey<T> {
  final String key;
  final T defaultValue;

  const SettingsKey(this.key, this.defaultValue);

  T readFrom(SettingsStorage storage);
  Future<bool> writeTo(SettingsStorage storage, T value);

  @override
  bool operator ==(Object other) =>
      other is SettingsKey<dynamic> &&
      runtimeType == other.runtimeType &&
      key == other.key;

  @override
  int get hashCode => Object.hash(runtimeType, key);
}

class BoolSettingsKey extends SettingsKey<bool> {
  // ignore: avoid_positional_boolean_parameters
  const BoolSettingsKey(super.key, super.defaultValue);

  @override
  bool readFrom(SettingsStorage storage) =>
      storage.getBool(key, defaultValue: defaultValue);

  @override
  Future<bool> writeTo(SettingsStorage storage, bool value) =>
      storage.putBool(key, value: value);
}

class IntSettingsKey extends SettingsKey<int> {
  const IntSettingsKey(super.key, super.defaultValue);

  @override
  int readFrom(SettingsStorage storage) => storage.getInt(key, defaultValue);

  @override
  Future<bool> writeTo(SettingsStorage storage, int value) =>
      storage.putInt(key, value);
}

class DoubleSettingsKey extends SettingsKey<double> {
  const DoubleSettingsKey(super.key, super.defaultValue);

  @override
  double readFrom(SettingsStorage storage) =>
      storage.getDouble(key, defaultValue);

  @override
  Future<bool> writeTo(SettingsStorage storage, double value) =>
      storage.putDouble(key, value);
}

class StringSettingsKey extends SettingsKey<String> {
  const StringSettingsKey(super.key, super.defaultValue);

  @override
  String readFrom(SettingsStorage storage) =>
      storage.getString(key, defaultValue);

  @override
  Future<bool> writeTo(SettingsStorage storage, String value) =>
      storage.putString(key, value);
}

class NullableIntSettingsKey extends SettingsKey<int?> {
  const NullableIntSettingsKey(String key) : super(key, null);

  @override
  int? readFrom(SettingsStorage storage) {
    final raw = storage.getInt(key, _sentinelNullInt);
    return raw == _sentinelNullInt ? null : raw;
  }

  @override
  Future<bool> writeTo(SettingsStorage storage, int? value) =>
      storage.putInt(key, value ?? _sentinelNullInt);
}

class NullableStringSettingsKey extends SettingsKey<String?> {
  const NullableStringSettingsKey(String key) : super(key, null);

  @override
  String? readFrom(SettingsStorage storage) {
    final raw = storage.getString(key, _sentinelNullString);
    return raw == _sentinelNullString ? null : raw;
  }

  @override
  Future<bool> writeTo(SettingsStorage storage, String? value) =>
      storage.putString(key, value ?? _sentinelNullString);
}

class EnumSettingsKey<T extends Enum> extends SettingsKey<T> {
  final List<T> values;

  const EnumSettingsKey(super.key, super.defaultValue, this.values);

  @override
  T readFrom(SettingsStorage storage) {
    final raw = storage.getString(key, defaultValue.name);
    return values.firstWhere(
      (v) => v.name == raw,
      orElse: () => defaultValue,
    );
  }

  @override
  Future<bool> writeTo(SettingsStorage storage, T value) =>
      storage.putString(key, value.name);
}

class EnumSetSettingsKey<T extends Enum> extends SettingsKey<Set<T>> {
  final List<T> allValues;

  const EnumSetSettingsKey(super.key, super.defaultValue, this.allValues);

  @override
  Set<T> readFrom(SettingsStorage storage) {
    final raw = storage.getString(key, '');
    if (raw.isEmpty) return defaultValue;
    return raw
        .split(',')
        .map((name) => allValues.firstWhereOrNull((v) => v.name == name.trim()))
        .whereType<T>()
        .toSet();
  }

  @override
  Future<bool> writeTo(SettingsStorage storage, Set<T> value) =>
      storage.putString(key, value.map((v) => v.name).join(','));
}
