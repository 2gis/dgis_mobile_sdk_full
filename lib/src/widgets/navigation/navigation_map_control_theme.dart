import 'package:flutter/widgets.dart';

import '../common/dgis_color_scheme.dart';
import '../map/map_widget_color_scheme.dart';

class NavigationMapControlTheme extends MapWidgetColorScheme {
  final double size;
  final double borderRadius;

  final Color surfaceColor;
  final Color surfacePressedColor;
  final Color dividerColor;

  final double iconSize;

  final Color iconDisabledColor;
  final Color iconInactiveColor;
  final Color iconActiveColor;

  final List<BoxShadow> shadows;

  const NavigationMapControlTheme({
    required this.size,
    required this.borderRadius,
    required this.surfaceColor,
    required this.surfacePressedColor,
    required this.iconSize,
    required this.iconDisabledColor,
    required this.iconInactiveColor,
    required this.iconActiveColor,
    this.dividerColor = DgisColorScheme.dividerColor,
    this.shadows = const [
      BoxShadow(
        offset: Offset(0, 1),
        color: DgisColorScheme.shadow8P,
        blurRadius: 4,
      ),
      BoxShadow(
        color: DgisColorScheme.shadow4P,
        spreadRadius: 0.5,
      ),
    ],
  });

  /// Widget color scheme for default light mode.
  static const NavigationMapControlTheme defaultLight =
      NavigationMapControlTheme(
        size: 44,
        borderRadius: 8,
        surfaceColor: DgisColorScheme.surfaceLightTheme,
        surfacePressedColor: DgisColorScheme.pressedSurfaceLightTheme,
        iconSize: 42,
        iconInactiveColor: DgisColorScheme.dimmedGrey,
        iconDisabledColor: DgisColorScheme.dimmedLightGrey,
        iconActiveColor: DgisColorScheme.activeBlueLight,
      );

  /// Widget color scheme for default dark mode.
  static const NavigationMapControlTheme defaultDark =
      NavigationMapControlTheme(
        size: 44,
        borderRadius: 8,
        surfaceColor: DgisColorScheme.surfaceDarkTheme,
        surfacePressedColor: DgisColorScheme.pressedSurfaceDarkTheme,
        iconSize: 42,
        iconInactiveColor: DgisColorScheme.dimmedLightGrey,
        iconDisabledColor: DgisColorScheme.disabledGrey,
        iconActiveColor: DgisColorScheme.activeBlueDark,
      );

  @override
  NavigationMapControlTheme copyWith({
    double? size,
    double? borderRadius,
    Color? surfaceColor,
    Color? surfacePressedColor,
    Color? dividerColor,
    double? iconSize,
    Color? iconDisabledColor,
    Color? iconInactiveColor,
    Color? iconActiveColor,
    List<BoxShadow>? shadows,
  }) {
    return NavigationMapControlTheme(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      surfacePressedColor: surfacePressedColor ?? this.surfacePressedColor,
      dividerColor: dividerColor ?? this.dividerColor,
      iconSize: iconSize ?? this.iconSize,
      iconDisabledColor: iconDisabledColor ?? this.iconDisabledColor,
      iconInactiveColor: iconInactiveColor ?? this.iconInactiveColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
      shadows: shadows ?? this.shadows,
    );
  }
}
