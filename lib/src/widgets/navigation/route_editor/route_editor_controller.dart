import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import './brief_info_provider.dart';
import './route_point_ui.dart';
import 'transport_mode.dart';

/// Controller for managing route editing functionality and route visualization.
///
/// This controller handles:
/// * Active transport type selection and switching
/// * Route points management
/// * Active route index selection
/// * Brief route information for all transport types
/// * Route parameters configuration
///
/// The controller requires a [routeEditor] instance and optionally accepts
/// [availableTransportModes], [transportTypeOptionsProvider], and [briefInfoProvider].
///
/// Usage example:
/// ```dart
/// final controller = RouteEditorController(
///   routeEditor: routeEditor,
///   availableTransportModes: [
///     TransportMode.car,
///     TransportMode.pedestrian,
///     TransportMode.publicTransport,
///   ],
/// );
///
/// // Set route points
/// controller.setRoutePoints([
///   RoutePointUI(point: startPoint, label: 'Start'),
///   RoutePointUI(point: endPoint, label: 'End'),
/// ]);
///
/// // Change transport type
/// controller.setActiveTransportMode(TransportMode.pedestrian);
///
/// // Select a route
/// controller.setActiveRouteIndex(0);
///
/// // Access brief info for all transport types
/// controller.briefInfoProvider.addListener(() {
///   final briefInfo = controller.briefInfoProvider.value;
///   print('Duration for car: ${briefInfo[TransportMode.car]?.duration}');
/// });
/// ```
///
/// The controller manages its state through multiple ValueNotifiers:
/// * [activeTransportMode] - Currently selected transport type
/// * [routePoints] - List of route points
/// * [briefInfoProvider] - Brief route information for all transport types
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class RouteEditorController {
  /// The route editor instance from the SDK.
  final sdk.RouteEditor routeEditor;

  /// List of transport types available for route calculation.
  final List<TransportMode> availableTransportModes;

  /// Provider for transport type-specific route search options.
  final TransportModeOptionsProvider transportTypeOptionsProvider;

  /// Provider for brief route information across all transport types.
  ///
  /// This provider automatically updates when route points or routes change,
  /// providing duration and other brief info for each transport type.
  final BriefInfoProvider briefInfoProvider;

  /// Currently active transport type.
  ///
  /// Changes to this value trigger route recalculation with the new transport type.
  final ValueNotifier<TransportMode?> activeTransportMode = ValueNotifier(null);

  /// Current list of route points.
  ///
  /// Must contain at least 2 points (start and finish) to calculate a route.
  final ValueNotifier<List<RoutePointUI>> routePoints = ValueNotifier([]);

  RouteEditorController({
    required this.routeEditor,
    this.availableTransportModes = TransportMode.values,
    TransportModeOptionsProvider? transportTypeOptionsProvider,
    BriefInfoProvider? briefInfoProvider,
  })  : transportTypeOptionsProvider = transportTypeOptionsProvider ??
            const DefaultTransportModeOptionsProvider(),
        briefInfoProvider =
            briefInfoProvider ?? ActiveRouteBriefInfoProvider() {
    if (availableTransportModes.isNotEmpty) {
      activeTransportMode.value = availableTransportModes.first;
    }
    this.briefInfoProvider.initialize(this);
  }

  /// Sets the active route by index.
  ///
  /// This updates the route editor to highlight and use the specified route.
  /// The [index] must be valid for the current routes list.
  ///
  /// Throws an exception if the route editor fails to set the index.
  void setActiveRouteIndex(int index) {
    withBssEventsSourceFromSdk(
      () => routeEditor.setActiveRouteIndex(sdk.RouteIndex(index)),
    );
  }

  (sdk.RouteSearchPoint?, sdk.RouteSearchPoint?, List<sdk.RouteSearchPoint>)
      _mapRoutePoints() {
    final firstPoint =
        routePoints.value.isNotEmpty ? routePoints.value.first.point : null;
    final lastPoint =
        routePoints.value.isNotEmpty ? routePoints.value.last.point : null;

    final intermediatePoints = routePoints.value.length > 2
        ? routePoints.value
            .sublist(1, routePoints.value.length - 1)
            .map((p) => p.point)
            .toList()
        : <sdk.RouteSearchPoint>[];

    return (firstPoint, lastPoint, intermediatePoints);
  }

  void _changeRouteType(sdk.RouteSearchOptions options) {
    final (startPoint, finishPoint, intermediatePoints) = _mapRoutePoints();

    if (startPoint == null || finishPoint == null) return;

    final newParams = sdk.RouteEditorRouteParams(
      startPoint: startPoint,
      finishPoint: finishPoint,
      intermediatePoints: intermediatePoints,
      routeSearchOptions: options,
    );

    withBssEventsSourceFromSdk(() => routeEditor.setRouteParams(newParams));
  }

  /// Changes the active transport type and recalculates the route.
  ///
  /// If the [type] is already active, this method does nothing.
  /// Otherwise, it updates the transport type and triggers route recalculation
  /// with the new transport type's options.
  void setActiveTransportMode(TransportMode type) {
    if (activeTransportMode.value == type) return;

    activeTransportMode.value = type;

    final options = transportTypeOptionsProvider.provide(type);
    _changeRouteType(options);
  }

  /// Sets the route points and recalculates the route.
  ///
  /// The [points] list must contain at least 2 points (start and finish).
  /// Points between the first and last are treated as intermediate waypoints.
  ///
  /// Throws [ArgumentError] if fewer than 2 points are provided.
  /// Throws an exception if the route editor fails to set the route parameters.
  void setRoutePoints(List<RoutePointUI> points) {
    if (points.length < 2) {
      throw ArgumentError('Route must have at least 2 points');
    }

    routePoints.value = List.unmodifiable(points);

    final activeType = activeTransportMode.value;
    if (activeType == null) return;

    final options = transportTypeOptionsProvider.provide(activeType);
    final (startPoint, finishPoint, intermediatePoints) = _mapRoutePoints();

    if (startPoint == null || finishPoint == null) return;

    final params = sdk.RouteEditorRouteParams(
      startPoint: startPoint,
      finishPoint: finishPoint,
      intermediatePoints: intermediatePoints,
      routeSearchOptions: options,
    );

    withBssEventsSourceFromSdk(() => routeEditor.setRouteParams(params));
  }

  /// Disposes of the controller and releases all resources.
  ///
  /// This cancels all subscriptions and disposes of all ValueNotifiers.
  /// The controller should not be used after calling this method.
  void dispose() {
    activeTransportMode.dispose();
    routePoints.dispose();
    briefInfoProvider.dispose();
  }
}
