import 'package:flutter/material.dart';

// Вспомогательный виджет для создания "мягких" градиентов.
// Проблема в том, что градиенту необходимо задавать 2 списка:
// количество "остановок" и цвет с уровнем прозрачности для каждой остановки.
// При несовпадении длины списков будет ассерт – это неудобно.
// Для большой длины списков подбирать цвета и размер отрезков – неудобно.
// Этот виджет придуман как раз, чтобы удобно можно было создать очень мягкий
// градиент – нужно большое число "остановок", но при этом размер шага и цвет
// для каждого шага будет посчитан автоматически.
class ShadowGradient extends StatelessWidget {
  final int stops;
  final double startOpacity;
  final double endOpacity;
  final Alignment begin;
  final Alignment end;
  final double height;
  final BorderRadius borderRadius;
  final Color color;

  const ShadowGradient({
    required this.stops,
    required this.startOpacity,
    required this.endOpacity,
    required this.begin,
    required this.end,
    required this.height,
    required this.color,
    super.key,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final opacityStep = (endOpacity - startOpacity) / (stops - 1);

    final gradientColors = <Color>[];
    final gradientStops = <double>[];

    for (var i = 0; i < stops; i++) {
      final currentOpacity = startOpacity + (opacityStep * i);
      // ignore: deprecated_member_use
      gradientColors.add(color.withOpacity(currentOpacity));
      gradientStops.add(i / (stops - 1));
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
          stops: gradientStops,
        ),
      ),
    );
  }
}
