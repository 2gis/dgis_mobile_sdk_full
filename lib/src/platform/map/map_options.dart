import 'dart:core';
import 'dart:ui';

import 'package:async/async.dart';

import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/optional.dart';
import 'map_appearance.dart';
import 'map_theme.dart';

/// Параметры карты.
class MapOptions {
  /// Расположение камеры относительно карты.
  final sdk.CameraPosition position;

  /// Относительное расположение точки местоположения карты в пространстве
  /// вида камеры.
  final sdk.CameraPositionPoint positionPoint;

  /// Границы изменения масштаба карты.
  final sdk.CameraZoomRestrictions zoomRestrictions;

  /// Разрешающая способность дисплея устройства, в пикселях на дюйм.
  /// Должна быть положительной.
  final sdk.DevicePpi? devicePPI;

  /// Множитель, который вычисляется как отношение DPI к базовому DPI устройства.
  final sdk.DeviceDensity? deviceDensity;

  /// Источники данных карты.
  final List<sdk.Source>? sources;

  /// Начальный стиль карты.
  final sdk.Style? style;

  /// Начальный стиль карты с отложенной загрузкой.
  final CancelableOperation<sdk.Style>? styleFuture;

  /// Выбор темы внутри выбранного стиля карты с учётом окружения.
  final MapAppearance appearance;

  /// Максимально допустимая частота обновления карты.
  final sdk.Fps? maxFps;

  /// Максимально допустимая частота обновления карты в режиме сохранения энергии.
  final sdk.Fps? powerSavingMaxFps;

  /// Цвет фона до подгрузки стилей.
  final Color? backgroundColor;

  final String? stylePath;

  MapOptions({
    this.position = const sdk.CameraPosition(
      point: sdk.GeoPoint(
        latitude: sdk.Latitude(),
        longitude: sdk.Longitude(),
      ),
      zoom: sdk.Zoom(),
    ),
    this.positionPoint = const sdk.CameraPositionPoint(),
    this.zoomRestrictions = const sdk.CameraZoomRestrictions(),
    this.devicePPI,
    this.deviceDensity,
    this.sources,
    this.style,
    this.styleFuture,
    this.appearance = const AutomaticAppearance(
      MapTheme.defaultDayTheme(),
      MapTheme.defaultNightTheme(),
    ),
    this.maxFps,
    this.powerSavingMaxFps,
    this.backgroundColor,
    this.stylePath,
  });

  MapOptions copyWith({
    sdk.CameraPosition? position,
    sdk.CameraPositionPoint? positionPoint,
    sdk.CameraZoomRestrictions? zoomRestrictions,
    Optional<sdk.DevicePpi?>? devicePPI,
    Optional<sdk.DeviceDensity?>? deviceDensity,
    Optional<List<sdk.Source>?>? sources,
    Optional<sdk.Style?>? style,
    Optional<CancelableOperation<sdk.Style>?>? styleFuture,
    MapAppearance? appearance,
    Optional<sdk.Fps?>? maxFps,
    Optional<sdk.Fps?>? powerSavingMaxFps,
    Optional<Color?>? backgroundColor,
    Optional<String?>? stylePath,
  }) {
    return MapOptions(
      position: position ?? this.position,
      positionPoint: positionPoint ?? this.positionPoint,
      devicePPI: devicePPI != null ? devicePPI.value : this.devicePPI,
      deviceDensity:
          deviceDensity != null ? deviceDensity.value : this.deviceDensity,
      sources: sources != null ? sources.value : this.sources,
      style: style != null ? style.value : this.style,
      styleFuture: styleFuture != null ? styleFuture.value : this.styleFuture,
      appearance: appearance ?? this.appearance,
      maxFps: maxFps != null ? maxFps.value : this.maxFps,
      powerSavingMaxFps: powerSavingMaxFps != null
          ? powerSavingMaxFps.value
          : this.powerSavingMaxFps,
      backgroundColor: backgroundColor != null
          ? backgroundColor.value
          : this.backgroundColor,
      stylePath: stylePath != null ? stylePath.value : this.stylePath,
    );
  }
}
