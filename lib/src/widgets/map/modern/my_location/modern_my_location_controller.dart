import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../generated/dart_bindings.dart' as sdk;
import 'modern_my_location_model.dart';

/// Controller for managing the  my-location widget logic.
///
/// This controller handles:
/// * Tracking the camera follow state, enabled state, and location quality
///   via SDK [sdk.MyLocationControlModel] channels
/// * Delegating permission requests to the caller via [onPermissionRequest]
///
/// The controller exposes its state as a [ValueNotifier] so the widget
/// can reactively rebuild when the state changes.
///
/// Usage example:
/// ```dart
/// final controller = ModernMyLocationController(
///   map: mapInstance,
///   onPermissionRequest: () {
///     Permission.location.request();
///   },
///   onTapFeedback: () {
///     HapticFeedback.mediumImpact();
///   },
/// );
///
/// // Listen to state changes
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Permission required: ${model.isPermissionRequired}');
///   print('Follow state: ${model.followState}');
/// });
///
/// // Handle user interaction
/// controller.processTap();
/// ```
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class ModernMyLocationController {
  final sdk.Map map;

  /// Callback for requesting location permission.
  /// Called when the user taps the button and location quality is degraded.
  /// The SDK will automatically update the state via [sdk.MyLocationControlModel.locationQualityChannel]
  /// after permission is granted.
  final VoidCallback? onPermissionRequest;

  /// Optional haptic/audio feedback callback, called on every tap
  /// before any state checks (matching iOS `feedbackGenerator`).
  final VoidCallback? onTapFeedback;

  late final sdk.MyLocationControlModel _sdkModel;
  late final ValueNotifier<ModernMyLocationModel> _model;
  StreamSubscription<bool>? _isEnabledSubscription;
  StreamSubscription<sdk.CameraFollowState>? _followStateSubscription;
  StreamSubscription<sdk.LocationQuality>? _locationQualitySubscription;

  /// The current state of the location control as a [ValueNotifier].
  ValueNotifier<ModernMyLocationModel> get state => _model;

  ModernMyLocationController({
    required this.map,
    this.onPermissionRequest,
    this.onTapFeedback,
  }) {
    _init();
  }

  void _init() {
    _sdkModel = sdk.MyLocationControlModel(map);
    _model = ValueNotifier(
      ModernMyLocationModel(
        isEnabled: _sdkModel.isEnabled,
        followState: _sdkModel.followState,
        isPermissionRequired: _isPermissionRequired(_sdkModel.locationQuality),
      ),
    );

    _isEnabledSubscription = _sdkModel.isEnabledChannel.listen((enabled) {
      _model.value = _model.value.copyWith(isEnabled: enabled);
    });
    _followStateSubscription =
        _sdkModel.followStateChannel.listen((followState) {
      _model.value = _model.value.copyWith(followState: followState);
    });
    _locationQualitySubscription =
        _sdkModel.locationQualityChannel.listen((quality) {
      _model.value = _model.value
          .copyWith(isPermissionRequired: _isPermissionRequired(quality));
    });
  }

  /// Handles user interaction with the location button.
  ///
  /// If the SDK model is not enabled, does nothing.
  /// If location permission is required, calls [onPermissionRequest].
  /// Otherwise, triggers the SDK model to cycle through follow modes.
  void processTap() {
    onTapFeedback?.call();
    if (!_model.value.isEnabled) {
      return;
    }
    if (_model.value.isPermissionRequired) {
      onPermissionRequest?.call();
    } else {
      _sdkModel.onClicked();
    }
  }

  /// Releases all resources held by this controller.
  void dispose() {
    _isEnabledSubscription?.cancel();
    _followStateSubscription?.cancel();
    _locationQualitySubscription?.cancel();
    _model.dispose();
  }

  static bool _isPermissionRequired(sdk.LocationQuality quality) {
    switch (quality) {
      case sdk.LocationQuality.accurate:
        return false;
      case sdk.LocationQuality.degraded:
        return true;
    }
  }
}
