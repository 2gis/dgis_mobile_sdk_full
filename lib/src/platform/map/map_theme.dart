import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Тема для использования в карте.
@immutable
class MapTheme {
  /// Код стиля из редактора стилей.
  final String name;

  /// Цвет подложки, используемый до загрузки стилей и отображения подложки карты.
  /// В темах по умолчанию соответствует цвету подложки карты по умолчанию.
  final Color loadingBackground;

  /// Признак темы, определяющий режим (темный/светлый), для которого будет
  /// использоваться тема.
  /// При использовании ThemedMapControl, эти UI-элементы будут ориентироваться
  /// на данный признак при выборе MapControlTheme
  final MapThemeColorMode colorMode;

  const MapTheme({
    required this.name,
    required this.loadingBackground,
    this.colorMode = MapThemeColorMode.light,
  });

  const MapTheme.defaultDayTheme()
      : name = 'day',
        loadingBackground = const Color.fromARGB(255, 245, 242, 224),
        colorMode = MapThemeColorMode.light;

  const MapTheme.defaultNightTheme()
      : name = 'night',
        loadingBackground = const Color.fromARGB(255, 28, 34, 43),
        colorMode = MapThemeColorMode.dark;

  MapTheme copyWith({
    String? name,
    Color? loadingBackground,
    MapThemeColorMode? colorMode,
  }) {
    return MapTheme(
      name: name ?? this.name,
      loadingBackground: loadingBackground ?? this.loadingBackground,
      colorMode: colorMode ?? this.colorMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapTheme &&
          other.runtimeType == runtimeType &&
          other.name == name &&
          other.loadingBackground == loadingBackground &&
          other.colorMode == colorMode;

  @override
  int get hashCode {
    return Object.hash(name, loadingBackground, colorMode);
  }
}

/// Режим (темный/светлый) темы карты [MapTheme].
enum MapThemeColorMode { dark, light }
