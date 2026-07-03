import 'dart:ui';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/optional.dart';
import 'map_appearance.dart';
import 'map_theme.dart';

/// Параметры отображения карты во Flutter-виджете.
class MapWidgetOptions {
  /// Разрешающая способность дисплея устройства, в пикселях на дюйм.
  /// Если не задана, берется из MediaQuery при подключении виджета.
  final sdk.DevicePpi? devicePPI;

  /// Множитель, который вычисляется как отношение DPI к базовому DPI устройства.
  /// Если не задан, берется из MediaQuery при подключении виджета.
  final sdk.DeviceDensity? deviceDensity;

  /// Внешний вид карты и виджетов поверх нее в зависимости от окружения.
  final MapAppearance appearance;

  /// Цвет фона до подгрузки стилей.
  final Color? backgroundColor;

  const MapWidgetOptions({
    this.devicePPI,
    this.deviceDensity,
    this.appearance = const AutomaticAppearance(
      MapTheme.defaultDayTheme(),
      MapTheme.defaultNightTheme(),
    ),
    this.backgroundColor,
  });

  /// Цвет фона, который должен использоваться до первого отрисованного кадра.
  Color get loadingBackground =>
      backgroundColor ?? appearance.mapTheme.loadingBackground;

  MapWidgetOptions copyWith({
    Optional<sdk.DevicePpi?>? devicePPI,
    Optional<sdk.DeviceDensity?>? deviceDensity,
    MapAppearance? appearance,
    Optional<Color?>? backgroundColor,
  }) {
    return MapWidgetOptions(
      devicePPI: devicePPI != null ? devicePPI.value : this.devicePPI,
      deviceDensity:
          deviceDensity != null ? deviceDensity.value : this.deviceDensity,
      appearance: appearance ?? this.appearance,
      backgroundColor: backgroundColor != null
          ? backgroundColor.value
          : this.backgroundColor,
    );
  }
}
