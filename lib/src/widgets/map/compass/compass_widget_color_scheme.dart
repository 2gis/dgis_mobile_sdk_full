import 'package:flutter/material.dart';

import '../map_widget_color_scheme.dart';

/// Color scheme for CompassWidget.
class CompassWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;

  const CompassWidgetColorScheme({required this.surfaceColor});

  @override
  CompassWidgetColorScheme copyWith({Color? surfaceColor}) {
    return CompassWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
    );
  }
}
