import 'package:flutter/material.dart';

import '../../common/color_ramp.dart';
import '../map_widget_color_scheme.dart';

/// Color scheme for TrafficWidget.
class TrafficWidgetColorScheme extends MapWidgetColorScheme {
  final Color backgroundColor;
  final Color pressedBackgroundColor;
  final Color iconInactiveColor;
  final Color iconDisabledColor;
  final Color iconActiveColor;
  final Color loaderColor;
  final ColorRamp trafficColor;
  final TextStyle scoreTextStyle;
  final TextStyle scoreTextStyleEnabled;
  final Size scoreStrokeSize;
  final double borderWidth;
  final double iconSize;

  const TrafficWidgetColorScheme({
    required this.backgroundColor,
    required this.pressedBackgroundColor,
    required this.iconInactiveColor,
    required this.iconDisabledColor,
    required this.iconActiveColor,
    required this.loaderColor,
    required this.trafficColor,
    required this.scoreTextStyle,
    required this.scoreTextStyleEnabled,
    required this.scoreStrokeSize,
    required this.borderWidth,
    required this.iconSize,
  });

  @override
  TrafficWidgetColorScheme copyWith({
    Color? backgroundColor,
    Color? pressedBackgroundColor,
    Color? iconInactiveColor,
    Color? iconDisabledColor,
    Color? iconActiveColor,
    Color? loaderColor,
    ColorRamp? trafficColor,
    TextStyle? scoreTextStyle,
    TextStyle? scoreTextStyleEnabled,
    Size? scoreStrokeSize,
    double? borderWidth,
    double? iconSize,
  }) {
    return TrafficWidgetColorScheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
      loaderColor: loaderColor ?? this.loaderColor,
      trafficColor: trafficColor ?? this.trafficColor,
      scoreTextStyle: scoreTextStyle ?? this.scoreTextStyle,
      scoreTextStyleEnabled:
          scoreTextStyleEnabled ?? this.scoreTextStyleEnabled,
      scoreStrokeSize: scoreStrokeSize ?? this.scoreStrokeSize,
      borderWidth: borderWidth ?? this.borderWidth,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}
