import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';
import '../../widget_shadows.dart';

class SpeedometerTheme extends MapWidgetColorScheme {
  final double size;
  final double iconSize;

  final Color surfaceColor;
  final TextStyle textStyle;
  final List<BoxShadow> shadows;

  const SpeedometerTheme({
    required this.size,
    required this.iconSize,
    required this.textStyle,
    required this.shadows,
    required this.surfaceColor,
  });

  /// Widget color scheme for default light mode.
  static const defaultLight = SpeedometerTheme(
    surfaceColor: DgisColorScheme.surfaceLight,
    size: 64,
    iconSize: 28,
    textStyle: TextStyle(
      height: 1.14,
      color: DgisColorScheme.surfaceDark,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      letterSpacing: -0.67,
    ),
    shadows: WidgetShadows.naviWidgetBoxShadowsLight,
  );

  /// Widget color scheme for default dark mode.
  static const defaultDark = SpeedometerTheme(
    surfaceColor: DgisColorScheme.surfaceDark,
    size: 64,
    iconSize: 28,
    textStyle: TextStyle(
      height: 1.14,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 28,
      letterSpacing: -0.67,
    ),
    shadows: WidgetShadows.naviWidgetBoxShadowsDark,
  );

  @override
  SpeedometerTheme copyWith({
    double? size,
    double? iconSize,
    Color? surfaceColor,
    TextStyle? textStyle,
    List<BoxShadow>? shadows,
  }) {
    return SpeedometerTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      size: size ?? this.size,
      iconSize: iconSize ?? this.iconSize,
      textStyle: textStyle ?? this.textStyle,
      shadows: shadows ?? this.shadows,
    );
  }
}
