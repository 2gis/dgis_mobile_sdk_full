import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import './parking_model.dart';

/// Controller for managing parking locations visibility and state on the map.
///
/// This controller handles:
/// * Parking locations visibility toggling
/// * Parking layer state management
/// * Real-time parking visibility updates
///
/// The controller provides simple parking visualization control through [ParkingModel],
/// allowing users to show or hide available parking locations on the map.
///
/// Usage example:
/// ```dart
/// final controller = ParkingController(
///   map: mapInstance,
/// );
///
/// // Toggle parking locations visibility
/// controller.toggleParking();
///
/// // Check if parking layer is active
/// print(controller.state.value.isActive);
///
/// // Listen to parking visibility changes
/// controller.state.addListener(() {
///   final isVisible = controller.state.value.isActive;
///   print('Parking locations are ${isVisible ? "visible" : "hidden"}');
/// });
/// ```
///
/// The controller maintains a single subscription to parking visibility state
/// and provides a simple toggle mechanism for parking locations visualization.
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class ParkingController {
  final sdk.Map map;

  late sdk.ParkingControlModel _parkingControlModel;
  late StreamSubscription<bool> _stateSubscription;
  late ValueNotifier<ParkingModel> _model;

  ValueNotifier<ParkingModel> get state => _model;

  ParkingController({required this.map}) {
    _init();
  }

  void _init() {
    _parkingControlModel =
        withBssEventsSourceFromSdk(() => sdk.ParkingControlModel(map));
    _model =
        ValueNotifier(ParkingModel(isActive: _parkingControlModel.isEnabled));
    _stateSubscription =
        _parkingControlModel.isEnabledChannel.listen((newState) {
      _model.value = _model.value.copyWith(isActive: newState);
    });
  }

  void toggleParking() {
    _parkingControlModel.toggleParkingsVisibility();
  }

  void dispose() {
    _stateSubscription.cancel();
  }
}
