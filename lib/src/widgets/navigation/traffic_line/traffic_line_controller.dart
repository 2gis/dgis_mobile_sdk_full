import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import './traffic_line_model.dart';

/// Controller for managing traffic information and route progress visualization.
///
/// This controller handles:
/// * Route progress tracking
/// * Traffic speed conditions
/// * Road events monitoring (accidents, roadworks)
/// * Intermediate route points
/// * Dynamic route updates
///
/// The controller maintains real-time information about traffic conditions
/// and route progress through [TrafficLineModel].
///
/// Usage example:
/// ```dart
/// final controller = TrafficLineController(
///   navigationManager: navigationManagerInstance,
/// );
///
/// // Access current traffic information
/// print(controller.state.value.routeProgress);
/// print(controller.state.value.speedColors);
///
/// // Listen to traffic and route updates
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Route progress: ${(model.routeProgress * 100).toStringAsFixed(1)}%');
///   print('Road events: ${model.roadEvents.length}');
/// });
/// ```
///
/// The controller maintains three main subscriptions:
/// * Route information updates
/// * Route position updates
/// * Dynamic traffic information updates
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class TrafficLineController {
  final sdk.NavigationManager navigationManager;

  late StreamSubscription<sdk.RouteInfo> _routeChannelSubscription;
  late StreamSubscription<sdk.RoutePoint?> _routePositionChannelSubscription;
  late StreamSubscription<sdk.DynamicRouteInfo> _dynamicRouteInfoSubscription;

  late final ValueNotifier<TrafficLineModel> _model;

  /// The current state of traffic information as a [ValueNotifier].
  /// Contains route progress, traffic conditions, and road events.
  ValueNotifier<TrafficLineModel> get state => _model;

  TrafficLineController({required this.navigationManager}) {
    _init();
  }

  void _init() {
    _model = ValueNotifier(
      TrafficLineModel(
        intermediatePoints:
            navigationManager.uiModel.route.route.intermediatePoints.entries,
        routeLength: navigationManager
            .uiModel
            .route
            .route
            .geometry
            .length
            .millimeters
            .toDouble(),
        routePosition: navigationManager
            .uiModel
            .routePosition
            ?.distance
            .millimeters
            .toDouble(),
        routeProgress: 0,
        speedColors: navigationManager
            .uiModel
            .dynamicRouteInfo
            .traffic
            .speedColors
            .entries,
        roadEvents:
            navigationManager.uiModel.dynamicRouteInfo.roadEvents.entries,
      ),
    );

    _routeChannelSubscription = navigationManager.uiModel.routeChannel.listen((
      routeInfo,
    ) {
      _model.value = _model.value.copyWith(
        routeLength: routeInfo.route.geometry.length.millimeters.toDouble(),
        intermediatePoints: routeInfo.route.intermediatePoints.entries,
      );
      _updateRouteProgress();
    });

    _routePositionChannelSubscription = navigationManager
        .uiModel
        .routePositionChannel
        .listen((position) {
          if (position != null) {
            _model.value = _model.value.copyWith(
              routePosition: () => position.distance.millimeters.toDouble(),
            );
          }
          _updateRouteProgress();
        });

    _dynamicRouteInfoSubscription = navigationManager
        .uiModel
        .dynamicRouteInfoChannel
        .listen((dynamicRouteInfo) {
          _model.value = _model.value.copyWith(
            speedColors: dynamicRouteInfo.traffic.speedColors.entries,
            roadEvents: dynamicRouteInfo.roadEvents.entries
                .where(
                  (event) =>
                      event.value.eventType == sdk.RoadEventType.accident ||
                      event.value.eventType == sdk.RoadEventType.roadWorks,
                )
                .toList(),
          );
        });
  }

  void _updateRouteProgress() {
    if (_model.value.routeLength != 0 && _model.value.routePosition != null) {
      _model.value = _model.value.copyWith(
        routeProgress: _model.value.routePosition! / _model.value.routeLength,
      );
    }
  }

  void dispose() {
    _dynamicRouteInfoSubscription.cancel();
    _routeChannelSubscription.cancel();
    _routePositionChannelSubscription.cancel();
  }
}
