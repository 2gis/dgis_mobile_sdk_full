import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';
import 'my_location_model.dart';

enum _Behaviour {
  full(
    value: sdk.CameraBehaviour(
      position: sdk.FollowPosition(
        bearing: sdk.FollowBearing.on_,
        styleZoom: sdk.FollowStyleZoom.on_,
      ),
      tilt: sdk.FollowTilt.on_,
    ),
  ),
  withoutBearing(
    value: sdk.CameraBehaviour(
      position: sdk.FollowPosition(
        styleZoom: sdk.FollowStyleZoom.on_,
      ),
      tilt: sdk.FollowTilt.on_,
    ),
  );

  final sdk.CameraBehaviour value;
  const _Behaviour({required this.value});
}

/// Controller for managing map camera behavior and user location tracking modes.
///
/// This controller handles:
/// * Camera behavior changes
/// * Location tracking modes
/// * Location button state and icon
/// * User interaction with location tracking
///
/// Usage example:
/// ```dart
/// final controller = MyLocationController(
///   map: mapInstance,
/// );
///
/// // Check current state
/// print(controller.state.value.isActive);
///
/// // Handle user interaction
/// controller.processTap();
///
/// // Listen to state changes
/// controller.state.addListener(() {
///   final model = controller.state.value;
///   print('Active: ${model.isActive}');
///   print('Current behaviour: ${model.behaviour}');
/// });
/// ```
///
/// Remember to dispose of the controller when it's no longer needed:
/// ```dart
/// controller.dispose();
/// ```
class MyLocationController {
  final sdk.Map map;

  late StreamSubscription<sdk.CameraBehaviourChange>
      _cameraBehaviorChannelConnection;

  late final ValueNotifier<MyLocationModel> _model;

  bool get _isFollowPositionMode =>
      map.camera.state == sdk.CameraState.free &&
      map.camera.behaviour.newBehaviour.position != null;

  bool get _isHideable => _model.value.isHideable;
  sdk.CameraBehaviour get _currentBehaviour => _model.value.behaviour;

  /// The current state of location tracking as a [ValueNotifier]
  ValueNotifier<MyLocationModel> get state => _model;

  MyLocationController({required this.map}) {
    _init();
  }

  void _init() {
    _model = ValueNotifier(
      MyLocationModel(
        isActive: map.camera.behaviour.newBehaviour == _Behaviour.full.value ||
            map.camera.behaviour.newBehaviour ==
                _Behaviour.withoutBearing.value,
        behaviour: _Behaviour.full.value,
        isHideable: false,
        iconAssetName:
            'packages/$pluginName/assets/icons/dgis_follow_direction.svg',
      ),
    );
    _cameraBehaviorChannelConnection =
        map.camera.behaviourChannel.listen((change) {
      String iconAssetName;
      var isActive = false;
      if (change.newBehaviour == _Behaviour.full.value) {
        iconAssetName =
            'packages/$pluginName/assets/icons/dgis_follow_direction.svg';
        isActive = true;
      } else {
        iconAssetName =
            'packages/$pluginName/assets/icons/dgis_my_location.svg';
      }

      if (change.newBehaviour == _Behaviour.withoutBearing.value) {
        map.processEvent(sdk.RotateMapToNorthEvent());
        isActive = true;
      }
      _model.value = _model.value.copyWith(
        isActive: isActive,
        behaviour: change.newBehaviour,
        iconAssetName: iconAssetName,
      );
    });
  }

  /// Handles user interaction with the location button.
  ///
  /// Cycles through different tracking modes based on current state:
  /// * Switches between full tracking and north-aligned tracking
  /// * Handles hideable state
  /// * Updates button icon based on current mode
  void processTap() {
    if ((!_isHideable &&
            _currentBehaviour == _Behaviour.withoutBearing.value) ||
        !_isFollowPositionMode) {
      _model.value = _model.value.copyWith(
        behaviour: _Behaviour.full.value,
        iconAssetName:
            'packages/$pluginName/assets/icons/dgis_follow_direction.svg',
      );
      map.camera.setBehaviour(_Behaviour.full.value);
      return;
    } else if (!_isHideable) {
      _model.value = _model.value.copyWith(
        behaviour: _Behaviour.withoutBearing.value,
        iconAssetName: 'packages/$pluginName/assets/icons/dgis_my_location.svg',
      );
      map.camera.setBehaviour(_Behaviour.withoutBearing.value);
      map.processEvent(sdk.RotateMapToNorthEvent());
      return;
    }
    _model.value = _model.value.copyWith(
      behaviour: _Behaviour.full.value,
      iconAssetName:
          'packages/$pluginName/assets/icons/dgis_follow_direction.svg',
    );
    map.camera.setBehaviour(_Behaviour.full.value);
  }

  void dispose() {
    _cameraBehaviorChannelConnection.cancel();
  }
}
