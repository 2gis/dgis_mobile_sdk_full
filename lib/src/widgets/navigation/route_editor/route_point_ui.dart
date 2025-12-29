import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;

@immutable
class RoutePointUI {
  final sdk.RouteSearchPoint point;
  final String label;

  const RoutePointUI({
    required this.point,
    required this.label,
  });

  RoutePointUI copyWith({
    sdk.RouteSearchPoint? point,
    String? label,
  }) {
    return RoutePointUI(
      point: point ?? this.point,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePointUI &&
          runtimeType == other.runtimeType &&
          point == other.point &&
          label == other.label;

  @override
  int get hashCode => Object.hash(point, label);
}

extension RoutePointUIGeoPoint on RoutePointUI {
  static RoutePointUI fromGeoPoint(sdk.GeoPoint geoPoint) {
    final label =
        '${geoPoint.latitude.value.toStringAsFixed(4)}, ${geoPoint.longitude.value.toStringAsFixed(4)}';
    return RoutePointUI(
      point: sdk.RouteSearchPoint(coordinates: geoPoint),
      label: label,
    );
  }
}
