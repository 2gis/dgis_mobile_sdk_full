import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../platform/bss_events_source.dart';
import './../../../generated/dart_bindings.dart' as sdk;
import './finish_route_model.dart';

/// Controller for managing the finish route functionality and parking visibility state.
///
/// This controller handles:
/// * Parking visibility toggle functionality
/// * Navigation termination
/// * Parking state management
///
/// The controller requires both [navigationManager] and [map] instances to function properly.
///
/// Usage example:
/// ```dart
/// final controller = FinishRouteController(
///   map: mapInstance,
///   navigationManager: navigationManagerInstance,
/// );
///
/// // Access parking state
/// print(controller.state.value.isParkingEnabled);
///
/// // Toggle parking visibility
/// controller.toggleParkingsVisibility();
///
/// // Stop navigation
/// controller.stopNavigation();
/// ```
///
/// The controller manages its state through [FinishRouteModel] which contains
/// information about parking visibility status. State changes can be observed
/// through the [state] ValueNotifier.
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
///
/// The controller exposes [sdk.Map] and [sdk.NavigationManager] instances
/// for advanced customization if needed.
class FinishRouteController {
  final sdk.Map map;
  final sdk.NavigationManager navigationManager;

  late sdk.ParkingControlModel _parkingControlModel;
  late final StreamSubscription<bool> _isParkingsEnabledSubscription;

  late final ValueNotifier<FinishRouteModel> _model;

  bool get _isParkingEnabled => _parkingControlModel.isEnabled;

  /// The current state as a [ValueNotifier].
  /// Contains parking visibility state.
  ValueNotifier<FinishRouteModel> get state => _model;

  FinishRouteController({required this.map, required this.navigationManager}) {
    _init();
  }

  void _init() {
    _parkingControlModel =
        withBssEventsSourceFromSdk(() => sdk.ParkingControlModel(map));
    _isParkingsEnabledSubscription =
        _parkingControlModel.isEnabledChannel.listen((isEnabled) {
      _model.value = _model.value.copyWith(isParkingEnabled: isEnabled);
    });
    _model = ValueNotifier(
      FinishRouteModel(isParkingEnabled: _isParkingEnabled),
    );
  }

  /// Stops the current navigation session.
  void stopNavigation() {
    navigationManager.stop();
  }

  /// Toggles the visibility of parking locations on the map.
  /// Updates the [state] with new parking visibility status.
  void toggleParkingsVisibility() {
    _parkingControlModel.toggleParkingsVisibility();
    _model.value = _model.value.copyWith(isParkingEnabled: _isParkingEnabled);
  }

  /// Cleans up resources by canceling subscriptions.
  /// Should be called when the controller is no longer needed.
  void dispose() {
    _isParkingsEnabledSubscription.cancel();
  }
}
