import 'package:meta/meta.dart';

import '../../../generated/dart_bindings.dart' as sdk;
import 'traffic_line_point_event_type.dart';

/// Represents a point event on the traffic line, such as road works or accidents.
/// Contains the point's location, type of event, and a unique identifier.
@immutable
class TrafficLinePointEvent {
  final sdk.RoutePoint point;
  final TrafficLinePointEventType type;
  final int id;

  const TrafficLinePointEvent({
    required this.point,
    required this.type,
    required this.id,
  });

  TrafficLinePointEvent copyWith({
    sdk.RoutePoint? point,
    TrafficLinePointEventType? type,
    int? id,
  }) {
    return TrafficLinePointEvent(
      point: point ?? this.point,
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrafficLinePointEvent &&
          runtimeType == other.runtimeType &&
          point == other.point &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => point.hashCode ^ type.hashCode ^ id.hashCode;
}
