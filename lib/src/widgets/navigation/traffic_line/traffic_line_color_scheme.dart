import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';
import '../../widget_shadows.dart';
import './traffic_line_segments_colors.dart';

class TrafficLineColorScheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color locationIconColor;
  final Color locationIconBackgroundColor;
  final Color passedColor;
  final List<BoxShadow> locationIconBoxShadows;
  final TrafficLineSegmentsColors trafficLineSegmentsColors;
  const TrafficLineColorScheme({
    required this.surfaceColor,
    required this.locationIconColor,
    required this.locationIconBackgroundColor,
    required this.passedColor,
    required this.locationIconBoxShadows,
    required this.trafficLineSegmentsColors,
  });

  /// Widget color scheme for default light mode.
  static const defaultLight = TrafficLineColorScheme(
    surfaceColor: DgisColorScheme.surfaceLight,
    locationIconColor: DgisColorScheme.surfaceLight,
    locationIconBackgroundColor: DgisColorScheme.darkGrey,
    passedColor: DgisColorScheme.blackNinePercent,
    locationIconBoxShadows: WidgetShadows.naviWidgetBoxShadowsLight,
    trafficLineSegmentsColors: TrafficLineSegmentsColors.defaultColors,
  );

  /// Widget color scheme for default dark mode.
  static const defaultDark = TrafficLineColorScheme(
    surfaceColor: DgisColorScheme.surfaceDark,
    locationIconColor: DgisColorScheme.surfaceDark,
    locationIconBackgroundColor: DgisColorScheme.surfaceLight,
    passedColor: DgisColorScheme.whiteSevenPercent,
    locationIconBoxShadows: WidgetShadows.naviWidgetBoxShadowsDark,
    trafficLineSegmentsColors: TrafficLineSegmentsColors.defaultColors,
  );
  @override
  TrafficLineColorScheme copyWith({
    Color? surfaceColor,
    Color? locationIconColor,
    Color? locationIconBackgroundColor,
    Color? passedColor,
    List<BoxShadow>? locationIconBoxShadows,
    TrafficLineSegmentsColors? trafficLineSegmentsColors,
  }) {
    return TrafficLineColorScheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      locationIconColor: locationIconColor ?? this.locationIconColor,
      locationIconBackgroundColor:
          locationIconBackgroundColor ?? this.locationIconBackgroundColor,
      locationIconBoxShadows:
          locationIconBoxShadows ?? this.locationIconBoxShadows,
      trafficLineSegmentsColors:
          trafficLineSegmentsColors ?? this.trafficLineSegmentsColors,
      passedColor: passedColor ?? this.passedColor,
    );
  }
}
