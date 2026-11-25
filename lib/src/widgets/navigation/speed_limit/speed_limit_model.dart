import 'package:flutter/foundation.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import '../../../util/plugin_name.dart';

@immutable
class SpeedLimitModel {
  final double? currentSpeed;
  final sdk.Location? location;
  final double? speedLimit;
  final bool exceeding;
  final sdk.CameraProgressInfo? cameraProgressInfo;

  const SpeedLimitModel({
    required this.currentSpeed,
    required this.location,
    required this.speedLimit,
    required this.exceeding,
    required this.cameraProgressInfo,
  });

  SpeedLimitModel copyWith({
    double? Function()? currentSpeed,
    sdk.Location? Function()? location,
    double? Function()? speedLimit,
    sdk.CameraProgressInfo? Function()? cameraProgressInfo,
    bool Function()? exceeding,
  }) {
    return SpeedLimitModel(
      currentSpeed: currentSpeed != null ? currentSpeed() : this.currentSpeed,
      location: location != null ? location() : this.location,
      speedLimit: speedLimit != null ? speedLimit() : this.speedLimit,
      exceeding: exceeding != null ? exceeding() : this.exceeding,
      cameraProgressInfo: cameraProgressInfo != null
          ? cameraProgressInfo()
          : this.cameraProgressInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SpeedLimitModel &&
        other.currentSpeed == currentSpeed &&
        other.location == location &&
        other.speedLimit == speedLimit &&
        other.exceeding == exceeding &&
        other.cameraProgressInfo == cameraProgressInfo;
  }

  @override
  int get hashCode => Object.hash(
    location,
    speedLimit,
    exceeding,
    cameraProgressInfo,
    currentSpeed,
  );

  @override
  String toString() =>
      'SpeedLimitModel('
      'currentSpeed: $currentSpeed, '
      'location: $location, '
      'speedLimit: $speedLimit, '
      'exceeding: $exceeding, '
      'cameraProgressInfo: $cameraProgressInfo'
      ')';

  String? cameraIcon() {
    if (cameraProgressInfo == null) {
      return null;
    }
    final purposes = cameraProgressInfo!.camera.purposes;

    if (purposes.contains(sdk.RouteCameraPurpose.noStoppingControl)) {
      return 'packages/$pluginName/assets/icons/navigation/dgis_camera_stop.svg';
    } else if (purposes.contains(sdk.RouteCameraPurpose.speedControl) ||
        purposes.contains(sdk.RouteCameraPurpose.averageSpeedControl)) {
      return switch (cameraProgressInfo!.camera.direction) {
        sdk.RouteCameraDirection.against =>
          'packages/$pluginName/assets/icons/navigation/dgis_camera_back.svg',
        sdk.RouteCameraDirection.along =>
          'packages/$pluginName/assets/icons/navigation/dgis_camera_front.svg',
        sdk.RouteCameraDirection.both =>
          'packages/$pluginName/assets/icons/navigation/dgis_camera_both.svg',
      };
    }

    return null;
  }
}
