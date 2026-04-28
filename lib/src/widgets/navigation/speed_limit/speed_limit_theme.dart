import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';

class SpeedLimitTheme extends MapWidgetColorScheme {
  final double size;
  final TextStyle textStyle;
  final TextStyle smallTextStyle;

  final Color surfaceColor;
  final Color exceededSurfaceColor;
  final TextStyle exceededTextStyle;
  final TextStyle smallExceededTextStyle;
  final List<BoxShadow> exceededShadows;

  final double borderWidth;

  const SpeedLimitTheme({
    required this.size,
    required this.borderWidth,
    required this.surfaceColor,
    required this.textStyle,
    required this.smallTextStyle,
    required this.exceededTextStyle,
    required this.smallExceededTextStyle,
    required this.exceededSurfaceColor,
    required this.exceededShadows,
  });

  /// Widget color scheme for default light mode.
  static const defaultLight = SpeedLimitTheme(
    size: 48,
    borderWidth: 4,
    surfaceColor: DgisColorScheme.surfaceLight,
    textStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceDark,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      letterSpacing: -0.48,
    ),
    smallTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceDark,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.55,
    ),
    exceededTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      letterSpacing: -0.48,
    ),
    smallExceededTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.55,
    ),
    exceededSurfaceColor: DgisColorScheme.speedometerRed,
    exceededShadows: [],
  );

  /// Widget color scheme for default dark mode.
  static const defaultDark = SpeedLimitTheme(
    surfaceColor: DgisColorScheme.surfaceDark,
    exceededSurfaceColor: DgisColorScheme.speedometerRed,
    borderWidth: 4,
    size: 48,
    exceededTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      letterSpacing: -0.48,
    ),
    smallExceededTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.55,
    ),
    textStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      letterSpacing: -0.48,
    ),
    smallTextStyle: TextStyle(
      height: 1.16,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      letterSpacing: -0.55,
    ),
    exceededShadows: [],
  );

  @override
  SpeedLimitTheme copyWith({
    double? size,
    double? borderWidth,
    Color? surfaceColor,
    TextStyle? textStyle,
    TextStyle? smallTextStyle,
    TextStyle? exceededTextStyle,
    TextStyle? smallExceededTextStyle,
    Color? exceededSurfaceColor,
    List<BoxShadow>? exceededShadows,
  }) {
    return SpeedLimitTheme(
      size: size ?? this.size,
      textStyle: textStyle ?? this.textStyle,
      smallTextStyle: smallTextStyle ?? this.smallTextStyle,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      borderWidth: borderWidth ?? this.borderWidth,
      exceededTextStyle: exceededTextStyle ?? this.exceededTextStyle,
      smallExceededTextStyle:
          smallExceededTextStyle ?? this.smallExceededTextStyle,
      exceededSurfaceColor: exceededSurfaceColor ?? this.exceededSurfaceColor,
      exceededShadows: exceededShadows ?? this.exceededShadows,
    );
  }
}
