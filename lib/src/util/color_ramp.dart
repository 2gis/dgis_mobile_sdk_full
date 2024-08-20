import 'dart:ui';

class ColorMark<T extends num> {
  final Color color;
  final T maxValue;

  const ColorMark({
    required this.color,
    required this.maxValue,
  });
}

class ColorRamp<T extends num> {
  final List<ColorMark<T>> colors;

  const ColorRamp({
    required this.colors,
  });

  Color getColor(T value) {
    int index = 0;

    while (index < colors.length - 1 && colors[index].maxValue < value) {
      index++;
    }

    return colors[index].color;
  }
}
