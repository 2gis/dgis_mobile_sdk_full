import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigation_setting_keys.dart';
import 'settings_key.dart';
import 'settings_storage.dart';
import 'shared_preferences_storage.dart';

/// A setting whose changes are saved only while its `remember` flag is true.
typedef _RememberScoped = ({
  BoolSettingsKey remember,
  SettingsKey<Object?> key,
});

const List<_RememberScoped> _rememberScoped = [
  (
    remember: NavigationSettingKeys.ptRememberChoice,
    key: NavigationSettingKeys.ptTransportTypes,
  ),
];

class NavigationSettingsRepository {
  final SettingsStorage _storage;
  final _notifiers = <String, ValueNotifier<dynamic>>{};

  /// Values of remember-scoped settings that are not saved to [_storage].
  final _sessionValues = <String, Object?>{};
  bool _disposed = false;

  NavigationSettingsRepository._(this._storage);

  @visibleForTesting
  NavigationSettingsRepository.forTesting(SettingsStorage storage)
      : _storage = storage;

  static Future<NavigationSettingsRepository> defaults() async {
    final prefs = await SharedPreferences.getInstance();
    return NavigationSettingsRepository._(SharedPreferencesStorage(prefs));
  }

  T get<T>(SettingsKey<T> key) {
    _checkNotDisposed();
    return _read(key);
  }

  /// Updates the value and notifies observers immediately.
  ///
  /// The returned future completes with the result of persisting the value
  /// to storage and may be ignored if durability does not matter. A value
  /// that is not saved because its remember flag is off completes with true.
  Future<bool> set<T>(SettingsKey<T> key, T value) {
    _checkNotDisposed();
    final Future<bool> write;
    if (_isSessionOnly(key)) {
      _sessionValues[key.key] = value;
      write = SynchronousFuture(true);
    } else if (value is bool && _isRememberFlag(key)) {
      write = _setRememberFlag(key as BoolSettingsKey, value);
    } else {
      write = key.writeTo(_storage, value);
    }
    _notifierFor(key).value = value;
    return write;
  }

  ValueListenable<T> observe<T>(SettingsKey<T> key) {
    _checkNotDisposed();
    return _notifierFor(key);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final notifier in _notifiers.values) {
      notifier.dispose();
    }
    _notifiers.clear();
    _sessionValues.clear();
  }

  T _read<T>(SettingsKey<T> key) {
    if (_sessionValues.containsKey(key.key)) {
      return _sessionValues[key.key] as T;
    }
    if (_isSessionOnly(key)) {
      return key.defaultValue;
    }
    return key.readFrom(_storage);
  }

  bool _isSessionOnly(SettingsKey<Object?> key) => _rememberScoped.any(
        (scoped) => scoped.key == key && !scoped.remember.readFrom(_storage),
      );

  bool _isRememberFlag(SettingsKey<Object?> key) =>
      _rememberScoped.any((scoped) => scoped.remember == key);

  /// Switches saving of the settings guarded by [flag].
  ///
  /// The current values stay in effect: turning saving on writes them to
  /// storage, turning it off keeps them in memory and leaves the saved values
  /// untouched.
  Future<bool> _setRememberFlag(BoolSettingsKey flag, bool remember) {
    final writes = <Future<bool>>[];
    if (flag.readFrom(_storage) != remember) {
      for (final scoped in _rememberScoped.where((s) => s.remember == flag)) {
        final current = _read(scoped.key);
        if (remember) {
          writes.add(scoped.key.writeTo(_storage, current));
          _sessionValues.remove(scoped.key.key);
        } else {
          _sessionValues[scoped.key.key] = current;
        }
      }
    }
    writes.add(flag.writeTo(_storage, remember));
    return Future.wait(writes).then((results) => results.every((ok) => ok));
  }

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError(
        'NavigationSettingsRepository was used after dispose().',
      );
    }
  }

  ValueNotifier<T> _notifierFor<T>(SettingsKey<T> key) {
    final notifier = _notifiers.putIfAbsent(
      key.key,
      () => ValueNotifier<T>(_read(key)),
    );
    if (notifier is! ValueNotifier<T>) {
      throw StateError(
        'Settings key "${key.key}" is already in use with a different value '
        'type: expected ValueNotifier<$T>, found ${notifier.runtimeType}.',
      );
    }
    return notifier;
  }
}
