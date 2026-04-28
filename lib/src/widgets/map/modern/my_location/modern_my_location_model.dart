import 'package:flutter/foundation.dart';

import '../../../../generated/dart_bindings.dart' as sdk;

/// Immutable state model for the modern my-location control.
///
/// Represents the current state of the location control,
/// including permission status, SDK model readiness,
/// and camera follow mode.
@immutable
class ModernMyLocationModel {
  /// Whether the SDK location control model is enabled and ready.
  final bool isEnabled;

  /// Current camera follow state (off, followPosition, followDirection).
  final sdk.CameraFollowState followState;

  /// Whether location permission is required (derived from LocationQuality).
  /// `true` when location quality is degraded (no permission or service off).
  final bool isPermissionRequired;

  const ModernMyLocationModel({
    required this.isEnabled,
    required this.followState,
    required this.isPermissionRequired,
  });

  ModernMyLocationModel copyWith({
    bool? isEnabled,
    sdk.CameraFollowState? followState,
    bool? isPermissionRequired,
  }) {
    return ModernMyLocationModel(
      isEnabled: isEnabled ?? this.isEnabled,
      followState: followState ?? this.followState,
      isPermissionRequired: isPermissionRequired ?? this.isPermissionRequired,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModernMyLocationModel &&
        other.isEnabled == isEnabled &&
        other.followState == followState &&
        other.isPermissionRequired == isPermissionRequired;
  }

  @override
  int get hashCode => Object.hash(isEnabled, followState, isPermissionRequired);

  @override
  String toString() => 'ModernMyLocationModel('
      'isEnabled: $isEnabled, '
      'followState: $followState, '
      'isPermissionRequired: $isPermissionRequired'
      ')';
}
