import 'package:flutter/widgets.dart';

import '../../common/color_ramp.dart';
import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';
import '../navigation_map_control_theme.dart';

class TrafficWidgetTheme extends MapWidgetColorScheme {
  final ColorRamp<int> trafficColor;
  final double borderWidth;
  final Color loaderColor;
  final TextStyle scoreTextStyle;
  final Size scoreStrokeSize;
  final double iconSize;
  final NavigationMapControlTheme controlTheme;

  const TrafficWidgetTheme({
    required this.scoreStrokeSize,
    required this.trafficColor,
    required this.borderWidth,
    required this.loaderColor,
    required this.scoreTextStyle,
    required this.iconSize,
    required this.controlTheme,
  });

  /// Widget color scheme for default light mode.
  static const TrafficWidgetTheme defaultLight = TrafficWidgetTheme(
    scoreStrokeSize: Size(24, 24),
    trafficColor: ColorRamp(
      colors: [
        ColorMark(
          color: DgisColorScheme.trafficGreen,
          maxValue: 3,
        ),
        ColorMark(
          color: DgisColorScheme.trafficYellow,
          maxValue: 6,
        ),
        ColorMark(
          color: DgisColorScheme.trafficRed,
          maxValue: 999,
        ),
      ],
    ),
    borderWidth: 2,
    loaderColor: DgisColorScheme.trafficGreen,
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: DgisColorScheme.dimmedGrey,
      fontSize: 19,
    ),
    iconSize: 24,
    controlTheme: NavigationMapControlTheme.defaultLight,
  );

  /// Widget color scheme for default dark mode.
  static const TrafficWidgetTheme defaultDark = TrafficWidgetTheme(
    scoreStrokeSize: Size(24, 24),
    trafficColor: ColorRamp(
      colors: [
        ColorMark(
          color: DgisColorScheme.trafficGreen,
          maxValue: 3,
        ),
        ColorMark(
          color: DgisColorScheme.trafficYellow,
          maxValue: 6,
        ),
        ColorMark(
          color: DgisColorScheme.trafficRed,
          maxValue: 999,
        ),
      ],
    ),
    borderWidth: 2,
    loaderColor: DgisColorScheme.trafficGreen,
    scoreTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      height: 1,
      color: DgisColorScheme.dimmedSurfaceLight,
      fontSize: 19,
    ),
    iconSize: 24,
    controlTheme: NavigationMapControlTheme.defaultDark,
  );

  @override
  TrafficWidgetTheme copyWith({
    Size? scoreStrokeSize,
    ColorRamp<int>? trafficColor,
    double? borderWidth,
    Color? loaderColor,
    TextStyle? scoreTextStyle,
    double? iconSize,
    NavigationMapControlTheme? controlTheme,
  }) {
    return TrafficWidgetTheme(
      scoreStrokeSize: scoreStrokeSize ?? this.scoreStrokeSize,
      trafficColor: trafficColor ?? this.trafficColor,
      borderWidth: borderWidth ?? this.borderWidth,
      loaderColor: loaderColor ?? this.loaderColor,
      scoreTextStyle: scoreTextStyle ?? this.scoreTextStyle,
      iconSize: iconSize ?? this.iconSize,
      controlTheme: controlTheme ?? this.controlTheme,
    );
  }
}
