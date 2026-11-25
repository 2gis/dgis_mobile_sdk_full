import 'package:flutter/widgets.dart';

import '../../../generated/dart_bindings.dart' as sdk;

@immutable
class TrafficModel {
  final sdk.TrafficControlStatus status;
  final int? score;

  const TrafficModel({required this.score, required this.status});

  TrafficModel copyWith({
    sdk.TrafficControlStatus? status,
    int? Function()? score,
  }) {
    return TrafficModel(
      status: status ?? this.status,
      score: score != null ? score() : this.score,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrafficModel &&
        other.status == status &&
        other.score == score;
  }

  @override
  int get hashCode => Object.hash(status, score);

  @override
  String toString() =>
      'TrafficModel('
      'status: $status, '
      'score: $score'
      ')';
}
