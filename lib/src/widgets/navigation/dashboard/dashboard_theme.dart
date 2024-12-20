import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';
import '../../widget_shadows.dart';

class DashboardWidgetTheme extends MapWidgetColorScheme {
  final TextStyle valueTextStyle;
  final TextStyle unitTextStyle;

  final Color surfaceColor;
  final List<BoxShadow> shadows;
  final double borderRadius;

  final Color soundIconColor;
  final Color buttonSurfaceColor;
  final Color buttonNegativeSurfaceColor;
  final Color buttonPositiveSurfaceColor;
  final double buttonBorderRadius;
  final double buttonSize;
  final Color iconColor;
  final double iconSize;
  final Color expandedShadowColor;

  final TextStyle menuButtonTextStyle;
  final TextStyle menuButtonSubTextStyle;
  final TextStyle finishButtonTextStyle;

  const DashboardWidgetTheme({
    required this.expandedShadowColor,
    required this.shadows,
    required this.surfaceColor,
    required this.borderRadius,
    required this.valueTextStyle,
    required this.unitTextStyle,
    required this.buttonSurfaceColor,
    required this.buttonNegativeSurfaceColor,
    required this.buttonPositiveSurfaceColor,
    required this.buttonBorderRadius,
    required this.buttonSize,
    required this.iconColor,
    required this.iconSize,
    required this.menuButtonTextStyle,
    required this.menuButtonSubTextStyle,
    required this.finishButtonTextStyle,
    required this.soundIconColor,
  });

  /// Widget color scheme for default light mode.
  static const defaultLight = DashboardWidgetTheme(
    expandedShadowColor: DgisColorScheme.blackFiftyPercent,
    borderRadius: 16,
    surfaceColor: DgisColorScheme.surfaceLight,
    shadows: WidgetShadows.naviWidgetBoxShadowsLight,
    valueTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnLight,
      fontWeight: FontWeight.w500,
      fontSize: 22,
      height: 1.27,
    ),
    unitTextStyle: TextStyle(
      color: DgisColorScheme.secondaryTextColorOnLight,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.23,
    ),
    buttonSurfaceColor: DgisColorScheme.veryDarkGrey,
    buttonNegativeSurfaceColor: DgisColorScheme.negativeRed,
    buttonPositiveSurfaceColor: DgisColorScheme.positiveGreen,
    buttonBorderRadius: 8,
    buttonSize: 36,
    iconColor: DgisColorScheme.darkGrey,
    iconSize: 24,
    soundIconColor: DgisColorScheme.surfaceLight,
    menuButtonTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnLight,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    menuButtonSubTextStyle: TextStyle(
      color: DgisColorScheme.secondaryTextColorOnLight,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.3,
    ),
    finishButtonTextStyle: TextStyle(
      color: DgisColorScheme.textColorOnRed,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
  );

  /// Widget color scheme for default dark mode.
  static const defaultDark = DashboardWidgetTheme(
    expandedShadowColor: DgisColorScheme.blackFiftyPercent,
    borderRadius: 16,
    surfaceColor: DgisColorScheme.surfaceDark,
    shadows: WidgetShadows.naviWidgetBoxShadowsDark,
    valueTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnDark,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.22,
    ),
    unitTextStyle: TextStyle(
      color: DgisColorScheme.secondaryTextColorOnDark,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    buttonSurfaceColor: DgisColorScheme.blackSixPercent,
    buttonNegativeSurfaceColor: DgisColorScheme.negativeRed,
    buttonPositiveSurfaceColor: DgisColorScheme.positiveGreen,
    buttonBorderRadius: 8,
    buttonSize: 36,
    iconColor: DgisColorScheme.lightGrey,
    iconSize: 24,
    soundIconColor: DgisColorScheme.surfaceLight,
    menuButtonTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnDark,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 1.25,
    ),
    menuButtonSubTextStyle: TextStyle(
      color: DgisColorScheme.secondaryTextColorOnLight,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.3,
    ),
    finishButtonTextStyle: TextStyle(
      color: DgisColorScheme.textColorOnRed,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
  );

  @override
  DashboardWidgetTheme copyWith({
    Color? expandedShadowColor,
    double? borderRadius,
    Color? surfaceColor,
    List<BoxShadow>? shadows,
    TextStyle? valueTextStyle,
    TextStyle? unitTextStyle,
    Color? buttonSurfaceColor,
    Color? buttonNegativeSurfaceColor,
    Color? buttonPositiveSurfaceColor,
    double? buttonBorderRadius,
    double? buttonSize,
    Color? iconColor,
    double? iconSize,
    Color? soundIconColor,
    TextStyle? menuButtonTextStyle,
    TextStyle? menuButtonSubTextStyle,
    TextStyle? finishButtonTextStyle,
  }) {
    return DashboardWidgetTheme(
      expandedShadowColor: expandedShadowColor ?? this.expandedShadowColor,
      borderRadius: borderRadius ?? this.borderRadius,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      shadows: shadows ?? this.shadows,
      valueTextStyle: valueTextStyle ?? this.valueTextStyle,
      unitTextStyle: unitTextStyle ?? this.unitTextStyle,
      buttonSurfaceColor: buttonSurfaceColor ?? this.buttonSurfaceColor,
      buttonNegativeSurfaceColor:
          buttonNegativeSurfaceColor ?? this.buttonNegativeSurfaceColor,
      buttonPositiveSurfaceColor:
          buttonPositiveSurfaceColor ?? this.buttonPositiveSurfaceColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonSize: buttonSize ?? this.buttonSize,
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      menuButtonTextStyle: menuButtonTextStyle ?? this.menuButtonTextStyle,
      menuButtonSubTextStyle:
          menuButtonSubTextStyle ?? this.menuButtonSubTextStyle,
      finishButtonTextStyle:
          finishButtonTextStyle ?? this.finishButtonTextStyle,
      soundIconColor: soundIconColor ?? this.soundIconColor,
    );
  }
}
