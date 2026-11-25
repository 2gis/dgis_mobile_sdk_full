import '../../generated/dart_bindings.dart' as sdk;

extension ModelDistanceDuration on sdk.Model {
  /// Distance from the current position to the end of the route.
  int? distance() {
    final routeDistance = route.route.geometry.length.millimeters;
    final currentDistance = routePosition?.distance.millimeters;

    if (currentDistance == null) {
      return null;
    }

    return routeDistance - currentDistance;
  }

  /// Travel time from the current position to the end of the route.
  Duration? duration() {
    final routePosition = this.routePosition;
    final endPosition = route.route.geometry.last?.point;

    if (routePosition == null || endPosition == null) {
      return null;
    }

    final duration = dynamicRouteInfo.traffic.durations.calculateDuration(
      routePosition,
      endPosition,
    );

    return duration;
  }

  /// Indication that the navigation is in FreeRoam mode
  bool get isFreeRoam =>
      state != sdk.State.disabled && route.routeBuildOptions == null;
}
