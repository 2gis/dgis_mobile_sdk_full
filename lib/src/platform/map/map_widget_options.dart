import '../../generated/dart_bindings.dart' as sdk;
import '../../generated/optional.dart';

/// Параметры отображения карты во Flutter-виджете.
class MapWidgetOptions {
  /// Разрешающая способность дисплея устройства, в пикселях на дюйм.
  /// Если не задана, берется из MediaQuery при подключении виджета.
  final sdk.DevicePpi? devicePPI;

  /// Множитель, который вычисляется как отношение DPI к базовому DPI устройства.
  /// Если не задан, берется из MediaQuery при подключении виджета.
  final sdk.DeviceDensity? deviceDensity;

  const MapWidgetOptions({
    this.devicePPI,
    this.deviceDensity,
  });

  MapWidgetOptions copyWith({
    Optional<sdk.DevicePpi?>? devicePPI,
    Optional<sdk.DeviceDensity?>? deviceDensity,
  }) {
    return MapWidgetOptions(
      devicePPI: devicePPI != null ? devicePPI.value : this.devicePPI,
      deviceDensity:
          deviceDensity != null ? deviceDensity.value : this.deviceDensity,
    );
  }
}
