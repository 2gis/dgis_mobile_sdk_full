import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import 'compass_model.dart';

/// Controller for managing map compass functionality and bearing state.
///
/// This controller handles:
/// * Map bearing updates
/// * North alignment functionality
/// * Compass state management
///
/// The controller requires a [map] instance to function properly and manages
/// the compass bearing through [CompassModel].
///
/// Usage example:
/// ```dart
/// final controller = CompassController(
///   map: mapInstance,
/// );
///
/// // Access current bearing
/// print(controller.state.value.bearing);
///
/// // Rotate map to north
/// controller.rotateToNorth();
///
/// // Listen to bearing changes
/// controller.state.addListener(() {
///   final bearing = controller.state.value.bearing;
///   print('Map rotated to: $bearing degrees');
/// });
/// ```
///
/// The controller maintains the compass state through [CompassModel] which contains
/// the current map bearing in degrees. State changes can be observed through
/// the [state] ValueNotifier.
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class CompassController {
  final sdk.Map map;

  ValueNotifier<CompassModel> get state => _model;
  late final ValueNotifier<CompassModel> _model;

  late sdk.CompassControlModel _compassModel;
  late StreamSubscription<sdk.Bearing> _bearingSubscription;

  late double _previousAngle = 0;

  CompassController({required this.map}) {
    _init();
  }

  void rotateToNorth() {
    _compassModel.onClicked();
  }

  void _init() {
    _compassModel =
        withBssEventsSourceFromSdk(() => sdk.CompassControlModel(map));
    _previousAngle = _compassModel.bearing.value;
    _bearingSubscription = _compassModel.bearingChannel.listen((bearing) {
      if ((bearing.value - _previousAngle).abs() > 1.0) {
        _model.value = _model.value.copyWith(bearing: bearing.value);
        _previousAngle = bearing.value;
      }
    });
    _model = ValueNotifier(CompassModel(bearing: _compassModel.bearing.value));
  }

  void dispose() {
    _bearingSubscription.cancel();
  }
}
