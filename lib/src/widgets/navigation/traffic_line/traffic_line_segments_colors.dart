import 'package:flutter/widgets.dart';

class TrafficLineSegmentsColors {
  final Color undefined;
  final Color green;
  final Color yellow;
  final Color red;
  final Color deepRed;

  const TrafficLineSegmentsColors({
    required this.undefined,
    required this.deepRed,
    required this.green,
    required this.red,
    required this.yellow,
  });

  static const defaultColors = TrafficLineSegmentsColors(
    undefined: Color(0xFF007AFF),
    deepRed: Color(0xFFC51116),
    green: Color(0xFF1DB93C),
    red: Color(0xFFF5373C),
    yellow: Color(0xFFFFB814),
  );
}
