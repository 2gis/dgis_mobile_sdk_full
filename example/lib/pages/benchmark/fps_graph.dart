import 'package:flutter/material.dart';

import 'fps_graph_painter.dart';

class FPSGraph extends StatelessWidget {
  final List<double> fpsValues;
  final double lastFps;
  final double averageFps;
  final double onePercentLow;
  final double zeroPointOnePercentLow;
  final double maxFps;

  const FPSGraph({
    required this.fpsValues,
    required this.lastFps,
    required this.averageFps,
    required this.onePercentLow,
    required this.zeroPointOnePercentLow,
    this.maxFps = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomPaint(
              painter: FPSGraphPainter(fpsValues: fpsValues, maxFps: maxFps),
              child: Container(),
            ),
          ),
          Text(
            'FPS: ${lastFps.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Avg: ${averageFps.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '1%: ${onePercentLow.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '0.1%: ${zeroPointOnePercentLow.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
