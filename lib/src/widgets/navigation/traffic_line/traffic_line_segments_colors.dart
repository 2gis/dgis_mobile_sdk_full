import 'package:flutter/widgets.dart';

class TrafficLineSegmentsColors {
  final Color undefined;
  final Color green;
  final Color deepGreen;
  final Color orange;
  final Color yellow;
  final Color red;
  final Color deepRed;

  const TrafficLineSegmentsColors({
    required this.undefined,
    required this.deepRed,
    required this.green,
    required this.red,
    required this.yellow,
    required this.deepGreen,
    required this.orange,
  });

  static const defaultLight = TrafficLineSegmentsColors(
    undefined: Color(0xFF007AFF),
    deepRed: Color(0xFFC51116),
    green: Color(0xFF1DB93C),
    red: Color(0xFFF5373C),
    yellow: Color(0xFFFFB814),
    deepGreen: Color(0xFF1BA136),
    orange: Color(0xFFEFA701),
  );

  static const defaultDark = TrafficLineSegmentsColors(
    undefined: Color(0xFF3588FD),
    deepRed: Color(0xFFC51116),
    green: Color(0xFF1BA136),
    red: Color(0xFFE91C21),
    yellow: Color(0xFFEFA701),
    deepGreen: Color(0xFF18862E),
    orange: Color(0xFFDB9201),
  );
}
