import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../platform/bss_events_source.dart';
import './zoom_model.dart';

// Controller for managing map zoom functionality and zoom button states.
///
/// This controller handles:
/// * Zoom in/out operations
/// * Zoom buttons state management
/// * Continuous zoom functionality
/// * Zoom availability monitoring
///
/// The controller provides zoom control through [ZoomModel] and manages
/// the state of zoom buttons based on current map zoom constraints.
///
/// Usage example:
/// ```dart
/// final controller = ZoomController(
///   map: mapInstance,
/// );
///
/// // Check zoom buttons availability
/// print('Zoom in available: ${controller.state.value.zoomInEnabled}');
/// print('Zoom out available: ${controller.state.value.zoomOutEnabled}');
///
/// // Handle zoom in operation
/// controller.startZoomIn();  // Start zooming in
/// // ... after some time or user action
/// controller.endZoomIn();    // Stop zooming in
///
/// // Listen to zoom availability changes
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Zoom in ${model.zoomInEnabled ? "enabled" : "disabled"}');
///   print('Zoom out ${model.zoomOutEnabled ? "enabled" : "disabled"}');
/// });
/// ```
///
/// The controller maintains two subscriptions for monitoring zoom button states
/// and provides methods for both momentary and continuous zoom operations.
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class ZoomController {
  final sdk.Map map;

  late StreamSubscription<bool> _zoomInSubscription;
  late StreamSubscription<bool> _zoomOutSubscription;
  late sdk.ZoomControlModel _zoomControlModel;

  late ValueNotifier<ZoomModel> _model;

  ValueNotifier<ZoomModel> get state => _model;

  ZoomController({required this.map}) {
    _init();
  }

  void _init() {
    _zoomControlModel =
        withBssEventsSourceFromSdk(() => sdk.ZoomControlModel(map));

    _model = ValueNotifier(
      ZoomModel(
        zoomInEnabled:
            _zoomControlModel.isEnabled(sdk.ZoomControlButton.zoomIn).value,
        zoomOutEnabled:
            _zoomControlModel.isEnabled(sdk.ZoomControlButton.zoomOut).value,
      ),
    );

    _zoomInSubscription =
        _zoomControlModel.isEnabled(sdk.ZoomControlButton.zoomIn).listen(
      (isEnabled) {
        _model.value = _model.value.copyWith(zoomInEnabled: isEnabled);
      },
    );
    _zoomOutSubscription =
        _zoomControlModel.isEnabled(sdk.ZoomControlButton.zoomOut).listen(
      (isEnabled) {
        _model.value = _model.value.copyWith(zoomOutEnabled: isEnabled);
      },
    );
  }

  void startZoomIn() {
    _setPressed(sdk.ZoomControlButton.zoomIn, isPressed: true);
  }

  void endZoomIn() {
    _setPressed(sdk.ZoomControlButton.zoomIn, isPressed: false);
  }

  void startZoomOut() {
    _setPressed(sdk.ZoomControlButton.zoomOut, isPressed: true);
  }

  void endZoomOut() {
    _setPressed(sdk.ZoomControlButton.zoomOut, isPressed: false);
  }

  void _setPressed(sdk.ZoomControlButton button, {required bool isPressed}) {
    _zoomControlModel.setPressed(button, isPressed);
  }

  void dispose() {
    _zoomInSubscription.cancel();
    _zoomOutSubscription.cancel();
  }
}
