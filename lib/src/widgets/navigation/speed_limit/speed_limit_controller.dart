import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import 'speed_limit_model.dart';

/// Controller for managing speed limits, speed cameras, and speed violation monitoring
/// during navigation.
///
/// This controller handles:
/// * Current speed limit monitoring
/// * Speed limit violations detection
/// * Speed camera notifications
/// * User location tracking
/// * Route position monitoring
///
/// The controller provides comprehensive speed-related information through [SpeedLimitModel],
/// including current speed limits, violations, and speed camera warnings.
///
/// Usage example:
/// ```dart
/// final controller = SpeedLimitController(
///   navigationManager: navigationManagerInstance,
/// );
///
/// // Access current speed information
/// print(controller.state.value.speedLimit);
/// print(controller.state.value.exceeding);
///
/// // Listen to speed-related updates
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   if (model.exceeding) {
///     print('Warning: Speed limit exceeded!');
///   }
///   if (model.cameraProgressInfo != null) {
///     print('Approaching speed camera');
///   }
/// });
/// ```
///
/// The controller maintains six main subscriptions:
/// * Location updates for current speed
/// * Route updates for speed limit data
/// * Position updates for current speed limits
/// * Speed violation monitoring
/// * Speed camera notifications
/// * Navigation state changes
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class SpeedLimitController {
  final sdk.NavigationManager navigationManager;

  late sdk.CameraNotifier _cameraNotifier;
  sdk.FloatRouteLongAttribute? _speedLimits;

  late StreamSubscription<sdk.Location?> _locationSubscription;
  late StreamSubscription<sdk.RouteInfo> _routeSubscription;
  late StreamSubscription<sdk.RoutePoint?> _routePositionSubscription;
  late StreamSubscription<bool> _exceedingMaxSpeedLimitSubscription;
  late StreamSubscription<sdk.CameraProgressInfo?> _cameraProgressSubscription;
  late StreamSubscription<sdk.State?> _navigationStateSubscription;

  late ValueNotifier<SpeedLimitModel> _model;

  ValueNotifier<SpeedLimitModel> get state => _model;

  SpeedLimitController({required this.navigationManager}) {
    _init();
  }

  void _init() {
    _cameraNotifier = sdk.CameraNotifier(navigationManager.uiModel);

    _model = ValueNotifier(
      SpeedLimitModel(
        currentSpeed: _metersPerSecondToKilometerPerHour(
          navigationManager.uiModel.location?.groundSpeed?.value,
        ),
        location: navigationManager.uiModel.location,
        speedLimit: null,
        exceeding: navigationManager.uiModel.exceedingMaxSpeedLimit,
        cameraProgressInfo: _cameraNotifier.cameraProgress,
      ),
    );

    _locationSubscription = navigationManager.uiModel.locationChannel.listen((
      location,
    ) {
      _model.value = _model.value.copyWith(
        location: () => location,
        currentSpeed: () =>
            _metersPerSecondToKilometerPerHour(location?.groundSpeed?.value),
      );
    });
    _routeSubscription = navigationManager.uiModel.routeChannel.listen((route) {
      _speedLimits = route.route.maxSpeedLimits;
    });
    _routePositionSubscription = navigationManager.uiModel.routePositionChannel
        .listen((position) {
          if (position == null || _speedLimits == null) {
            return;
          }

          final entry = _speedLimits!.entry(position);
          _model.value = _model.value.copyWith(
            speedLimit: () => _metersPerSecondToKilometerPerHour(entry?.value),
          );
        });
    _exceedingMaxSpeedLimitSubscription = navigationManager
        .uiModel
        .exceedingMaxSpeedLimitChannel
        .listen((exceeding) {
          _model.value = _model.value.copyWith(
            exceeding: () => exceeding,
          );
        });
    _cameraProgressSubscription = _cameraNotifier.cameraProgressChannel.listen((
      cameraProgressInfo,
    ) {
      _model.value = _model.value.copyWith(
        cameraProgressInfo: () => cameraProgressInfo,
      );
    });

    _navigationStateSubscription = navigationManager.uiModel.stateChannel
        .listen((state) {
          final uiModel = navigationManager.uiModel;
          _model.value = _model.value.copyWith(
            currentSpeed: () => _metersPerSecondToKilometerPerHour(
              uiModel.location?.groundSpeed?.value,
            ),
            cameraProgressInfo: () => _cameraNotifier.cameraProgress,
            location: () => uiModel.location,
            exceeding: () => uiModel.exceedingMaxSpeedLimit,
          );
        });
  }

  double? _metersPerSecondToKilometerPerHour(double? mps) {
    if (mps == null) {
      return null;
    }
    return mps * 3.6;
  }

  void dispose() {
    _locationSubscription.cancel();
    _routeSubscription.cancel();
    _routePositionSubscription.cancel();
    _exceedingMaxSpeedLimitSubscription.cancel();
    _cameraProgressSubscription.cancel();
    _navigationStateSubscription.cancel();
  }
}
