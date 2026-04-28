import 'package:flutter/material.dart';

import '../../map_widget_color_scheme.dart';

/// Color scheme for ModernCompassWidget.
class ModernCompassWidgetColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;

  const ModernCompassWidgetColorScheme({required this.surfaceColor});

  @override
  ModernCompassWidgetColorScheme copyWith({Color? surfaceColor}) {
    return ModernCompassWidgetColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
    );
  }
}
