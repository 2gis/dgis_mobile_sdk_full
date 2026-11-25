import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';
import '../../widget_shadows.dart';

class ManeuverWidgetTheme extends MapWidgetColorScheme {
  final MainManeuverTheme mainManeuverTheme;
  final AdditionalManeuverTheme additionalManeuverTheme;

  const ManeuverWidgetTheme({
    required this.mainManeuverTheme,
    required this.additionalManeuverTheme,
  });

  /// Widget color scheme for default light mode.
  static const ManeuverWidgetTheme defaultLight = ManeuverWidgetTheme(
    mainManeuverTheme: MainManeuverTheme.defaultLight,
    additionalManeuverTheme: AdditionalManeuverTheme.defaultLight,
  );

  /// Widget color scheme for default dark mode.
  static const ManeuverWidgetTheme defaultDark = ManeuverWidgetTheme(
    mainManeuverTheme: MainManeuverTheme.defaultDark,
    additionalManeuverTheme: AdditionalManeuverTheme.defaultDark,
  );

  @override
  ManeuverWidgetTheme copyWith({
    MainManeuverTheme? mainManeuverTheme,
    AdditionalManeuverTheme? additionalManeuverTheme,
  }) {
    return ManeuverWidgetTheme(
      additionalManeuverTheme:
          additionalManeuverTheme ?? this.additionalManeuverTheme,
      mainManeuverTheme: mainManeuverTheme ?? this.mainManeuverTheme,
    );
  }
}

class MainManeuverTheme extends MapWidgetColorScheme {
  final TextStyle roadNameTextStyle;
  final TextStyle maneuverDistanceTextStyle;
  final TextStyle maneuverDistanceUnitTextStyle;
  final double iconSize;
  final double maxWidth;
  final double minWidth;
  final List<BoxShadow> shadows;
  final double borderRadius;
  final Color surfaceColor;

  const MainManeuverTheme({
    required this.roadNameTextStyle,
    required this.maneuverDistanceTextStyle,
    required this.maneuverDistanceUnitTextStyle,
    required this.iconSize,
    required this.maxWidth,
    required this.minWidth,
    required this.shadows,
    required this.borderRadius,
    required this.surfaceColor,
  });

  /// Widget color scheme for default light mode.
  static const MainManeuverTheme defaultLight = MainManeuverTheme(
    roadNameTextStyle: TextStyle(
      height: 1.25,
      color: DgisColorScheme.textDarkGrey,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    maneuverDistanceTextStyle: TextStyle(
      height: 1.14,
      color: DgisColorScheme.textDarkGrey,
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    maneuverDistanceUnitTextStyle: TextStyle(
      height: 1.2,
      color: DgisColorScheme.textDarkGrey,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    iconSize: 36,
    maxWidth: 150,
    minWidth: 150,
    borderRadius: 16,
    surfaceColor: DgisColorScheme.surfaceLight,
    shadows: WidgetShadows.naviWidgetBoxShadowsLight,
  );

  /// Widget color scheme for default dark mode.
  static const MainManeuverTheme defaultDark = MainManeuverTheme(
    roadNameTextStyle: TextStyle(
      height: 1.25,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    maneuverDistanceTextStyle: TextStyle(
      height: 1.14,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w500,
      fontSize: 28,
    ),
    maneuverDistanceUnitTextStyle: TextStyle(
      height: 1.2,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    iconSize: 36,
    maxWidth: 150,
    minWidth: 150,
    borderRadius: 16,
    surfaceColor: DgisColorScheme.surfaceDark,
    shadows: WidgetShadows.naviWidgetBoxShadowsDark,
  );

  @override
  MainManeuverTheme copyWith({
    TextStyle? roadNameTextStyle,
    TextStyle? maneuverDistanceTextStyle,
    TextStyle? maneuverDistanceUnitTextStyle,
    double? maxWidth,
    double? minWidth,
    double? iconSize,
    double? borderRadius,
    Color? surfaceColor,
    List<BoxShadow>? shadows,
  }) {
    return MainManeuverTheme(
      roadNameTextStyle: roadNameTextStyle ?? this.roadNameTextStyle,
      maneuverDistanceTextStyle:
          maneuverDistanceTextStyle ?? this.maneuverDistanceTextStyle,
      maneuverDistanceUnitTextStyle:
          maneuverDistanceUnitTextStyle ?? this.maneuverDistanceUnitTextStyle,
      maxWidth: maxWidth ?? this.maxWidth,
      minWidth: minWidth ?? this.minWidth,
      iconSize: iconSize ?? this.iconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      shadows: shadows ?? this.shadows,
    );
  }
}

class AdditionalManeuverTheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final TextStyle textStyle;
  final Size iconSize;
  final double containerHeight;
  final List<BoxShadow> shadows;
  final double containerBorderRadius;

  const AdditionalManeuverTheme({
    required this.textStyle,
    required this.surfaceColor,
    required this.iconSize,
    required this.containerHeight,
    required this.shadows,
    required this.containerBorderRadius,
  });

  /// Widget color scheme for default light mode.
  static const AdditionalManeuverTheme defaultLight = AdditionalManeuverTheme(
    textStyle: TextStyle(
      height: 1.2,
      color: DgisColorScheme.surfaceDark,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    surfaceColor: DgisColorScheme.whiteNinetyOnePercent,
    iconSize: Size(24, 24),
    containerHeight: 32,
    shadows: WidgetShadows.naviWidgetBoxShadowsLight,
    containerBorderRadius: 16,
  );

  /// Widget color scheme for default dark mode.
  static const AdditionalManeuverTheme defaultDark = AdditionalManeuverTheme(
    textStyle: TextStyle(
      height: 1.2,
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w500,
      fontSize: 20,
    ),
    surfaceColor: DgisColorScheme.darkGreyNinetyOnePercent,
    iconSize: Size(24, 24),
    containerHeight: 32,
    shadows: WidgetShadows.naviWidgetBoxShadowsDark,
    containerBorderRadius: 16,
  );

  @override
  MapWidgetColorScheme copyWith({
    TextStyle? textStyle,
    Color? surfaceColor,
    Size? iconSize,
    double? containerHeight,
    List<BoxShadow>? shadows,
    double? containerBorderRadius,
  }) {
    return AdditionalManeuverTheme(
      textStyle: textStyle ?? this.textStyle,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      iconSize: iconSize ?? this.iconSize,
      containerHeight: containerHeight ?? this.containerHeight,
      shadows: shadows ?? this.shadows,
      containerBorderRadius:
          containerBorderRadius ?? this.containerBorderRadius,
    );
  }
}
