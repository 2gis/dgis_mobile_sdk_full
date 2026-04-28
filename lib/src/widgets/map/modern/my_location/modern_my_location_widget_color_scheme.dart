import 'package:flutter/material.dart';

import '../../map_widget_color_scheme.dart';

class ModernMyLocationWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color iconDisabledColor;
  final Color iconInactiveColor;
  final Color iconActiveColor;

  const ModernMyLocationWidgetColorScheme({
    required this.surfaceColor,
    required this.iconDisabledColor,
    required this.iconInactiveColor,
    required this.iconActiveColor,
  });

  @override
  ModernMyLocationWidgetColorScheme copyWith({
    Color? surfaceColor,
    Color? iconDisabledColor,
    Color? iconInactiveColor,
    Color? iconActiveColor,
  }) {
    return ModernMyLocationWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
    );
  }
}
