import 'package:flutter/material.dart';

import '../map_widget_color_scheme.dart';

class MyLocationWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color iconDisabledColor;
  final Color iconInactiveColor;
  final Color iconActiveColor;

  const MyLocationWidgetColorScheme({
    required this.surfaceColor,
    required this.iconDisabledColor,
    required this.iconInactiveColor,
    required this.iconActiveColor,
  });

  @override
  MyLocationWidgetColorScheme copyWith({
    Color? surfaceColor,
    Color? iconDisabledColor,
    Color? iconInactiveColor,
    Color? iconActiveColor,
  }) {
    return MyLocationWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
    );
  }
}
