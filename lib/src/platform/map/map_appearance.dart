import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'map_theme.dart';

/// Внешний вид карты в зависимости от окружения.
sealed class MapAppearance {
  const MapAppearance();
}

/// Использовать тему по умолчанию.
class DefaultAppearance extends MapAppearance {
  const DefaultAppearance();
}

/// Использовать единую тему текущего стиля в любом окружении.
class UniversalAppearance extends MapAppearance {
  final MapTheme theme;

  const UniversalAppearance(this.theme);
}

/// Использовать автоматически переключающуюся светлую и тёмную тему.
class AutomaticAppearance extends MapAppearance {
  final MapTheme lightTheme;
  final MapTheme nightTheme;

  const AutomaticAppearance(this.lightTheme, this.nightTheme);
}

extension MakeMapTheme on MapAppearance {
  MapTheme get mapTheme {
    switch (this) {
      case DefaultAppearance():
        return const MapTheme.defaultDayTheme();
      case UniversalAppearance(theme: final theme):
        return theme;
      case AutomaticAppearance(
          lightTheme: final lightTheme,
          nightTheme: final nightTheme
        ):
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light ? lightTheme : nightTheme;
    }
  }
}
