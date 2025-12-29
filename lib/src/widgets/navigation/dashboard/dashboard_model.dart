import 'package:flutter/widgets.dart';

@immutable
class DashboardModel {
  final int distance;
  final int duration;
  final bool soundsEnabled;
  final bool isRouteViewMode;
  final bool isMinimapVisible;

  const DashboardModel({
    required this.distance,
    required this.duration,
    required this.soundsEnabled,
    this.isRouteViewMode = false,
    this.isMinimapVisible = false,
  });

  DashboardModel copyWith({
    int? distance,
    int? duration,
    bool? soundsEnabled,
    bool? isRouteViewMode,
    bool? isMinimapVisible,
  }) {
    return DashboardModel(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      isRouteViewMode: isRouteViewMode ?? this.isRouteViewMode,
      isMinimapVisible: isMinimapVisible ?? this.isMinimapVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardModel &&
        other.distance == distance &&
        other.duration == duration &&
        other.soundsEnabled == soundsEnabled &&
        other.isRouteViewMode == isRouteViewMode &&
        other.isMinimapVisible == isMinimapVisible;
  }

  @override
  int get hashCode => Object.hash(
        distance,
        duration,
        soundsEnabled,
        isRouteViewMode,
        isMinimapVisible,
      );

  @override
  String toString() => 'DashboardModel('
      'distance: $distance, '
      'duration: $duration, '
      'soundsEnabled: $soundsEnabled, '
      'isRouteViewMode: $isRouteViewMode, '
      'isMinimapVisible: $isMinimapVisible'
      ')';
}
