import 'package:flutter/material.dart';

class FPSGraphPainter extends CustomPainter {
  final List<double> fpsValues;
  final double maxFps;

  FPSGraphPainter({required this.fpsValues, required this.maxFps});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (fpsValues.isEmpty) return;

    final yValues = [0, maxFps / 2, maxFps];
    for (final yValue in yValues) {
      final y = size.height - (yValue / maxFps) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      TextPainter(
        text: TextSpan(
          text: yValue.toStringAsFixed(0),
          // ignore: deprecated_member_use
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(maxWidth: size.width)
        ..paint(canvas, Offset(0, y - 10));
    }

    final widthPerFrame = size.width / (fpsValues.length - 1);

    for (var i = 0; i < fpsValues.length; i++) {
      final cappedFpsValue = fpsValues[i].clamp(0, maxFps);
      final yPosition = size.height - (cappedFpsValue / maxFps) * size.height;

      if (i == 0) {
        path.moveTo(0, yPosition);
      } else {
        path.lineTo(i * widthPerFrame, yPosition);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
