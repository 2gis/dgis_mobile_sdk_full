import 'package:flutter/widgets.dart';

import '../../common/dgis_color_scheme.dart';
import '../../map/map_widget_color_scheme.dart';

class FinishRouteWidgetTheme extends MapWidgetColorScheme {
  final Color surfaceColor;
  final Color surfaceColorSecondary;
  final TextStyle arrivalPhraseTextStyle;
  final Color inactiveButtonSurfaceColor;
  final Color activeButtonSurfaceColor;
  final TextStyle inactiveButtonsTextStyle;
  final TextStyle activeButtonsTextStyle;
  final double borderRadius;
  final Color buttonNegativeSurfaceColor;
  final double buttonBorderRadius;
  final TextStyle finishButtonTextStyle;
  final Color inactiveIconColor;
  final Color activeIconColor;
  final Size iconSize;

  const FinishRouteWidgetTheme({
    required this.borderRadius,
    required this.inactiveButtonSurfaceColor,
    required this.activeButtonSurfaceColor,
    required this.inactiveButtonsTextStyle,
    required this.activeButtonsTextStyle,
    required this.surfaceColor,
    required this.arrivalPhraseTextStyle,
    required this.buttonNegativeSurfaceColor,
    required this.buttonBorderRadius,
    required this.finishButtonTextStyle,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.iconSize,
    required this.surfaceColorSecondary,
  });

  static const FinishRouteWidgetTheme defaultLight = FinishRouteWidgetTheme(
    borderRadius: 16,
    inactiveButtonSurfaceColor: DgisColorScheme.veryDimmedGray,
    activeButtonSurfaceColor: DgisColorScheme.positiveGreen,
    inactiveButtonsTextStyle: TextStyle(
      fontSize: 14,
      height: 1.28,
      fontWeight: FontWeight.w500,
      color: DgisColorScheme.surfaceDark,
    ),
    activeButtonsTextStyle: TextStyle(
      fontSize: 14,
      height: 1.28,
      fontWeight: FontWeight.w500,
      color: DgisColorScheme.surfaceLight,
    ),
    surfaceColor: DgisColorScheme.surfaceLight,
    surfaceColorSecondary: DgisColorScheme.surfaceGrey,
    arrivalPhraseTextStyle: TextStyle(
      fontSize: 19,
      height: 1.24,
      fontWeight: FontWeight.w600,
      color: DgisColorScheme.surfaceDark,
    ),
    buttonNegativeSurfaceColor: DgisColorScheme.negativeRed,
    buttonBorderRadius: 8,
    finishButtonTextStyle: TextStyle(
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
    inactiveIconColor: DgisColorScheme.surfaceDark,
    activeIconColor: DgisColorScheme.surfaceLight,
    iconSize: Size(48, 48),
  );

  static const FinishRouteWidgetTheme defaultDark = FinishRouteWidgetTheme(
    borderRadius: 16,
    inactiveButtonSurfaceColor: DgisColorScheme.blackSixPercent,
    activeButtonSurfaceColor: DgisColorScheme.positiveGreen,
    inactiveButtonsTextStyle: TextStyle(
      fontSize: 14,
      height: 1.28,
      fontWeight: FontWeight.w500,
      color: DgisColorScheme.surfaceLight,
    ),
    activeButtonsTextStyle: TextStyle(
      fontSize: 14,
      height: 1.28,
      fontWeight: FontWeight.w500,
      color: DgisColorScheme.surfaceLight,
    ),
    surfaceColor: DgisColorScheme.surfaceDarkGrey,
    surfaceColorSecondary: DgisColorScheme.textDarkGrey,
    arrivalPhraseTextStyle: TextStyle(
      fontSize: 19,
      height: 1.24,
      fontWeight: FontWeight.w600,
      color: DgisColorScheme.surfaceLight,
    ),
    buttonNegativeSurfaceColor: DgisColorScheme.negativeRed,
    buttonBorderRadius: 8,
    finishButtonTextStyle: TextStyle(
      color: DgisColorScheme.surfaceLight,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.25,
    ),
    inactiveIconColor: DgisColorScheme.surfaceLight,
    activeIconColor: DgisColorScheme.surfaceLight,
    iconSize: Size(48, 48),
  );

  @override
  FinishRouteWidgetTheme copyWith({
    double? borderRadius,
    Color? inactiveButtonSurfaceColor,
    Color? activeButtonSurfaceColor,
    TextStyle? inactiveButtonsTextStyle,
    TextStyle? activeButtonsTextStyle,
    Color? surfaceColor,
    Color? surfaceColorSecondary,
    TextStyle? arrivalPhraseTextStyle,
    Color? buttonNegativeSurfaceColor,
    double? buttonBorderRadius,
    TextStyle? finishButtonTextStyle,
    Color? inactiveIconColor,
    Color? activeIconColor,
    Size? iconSize,
  }) {
    return FinishRouteWidgetTheme(
      borderRadius: borderRadius ?? this.borderRadius,
      inactiveButtonSurfaceColor:
          inactiveButtonSurfaceColor ?? this.inactiveButtonSurfaceColor,
      activeButtonSurfaceColor:
          activeButtonSurfaceColor ?? this.activeButtonSurfaceColor,
      inactiveButtonsTextStyle:
          inactiveButtonsTextStyle ?? this.inactiveButtonsTextStyle,
      activeButtonsTextStyle:
          activeButtonsTextStyle ?? this.activeButtonsTextStyle,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      arrivalPhraseTextStyle:
          arrivalPhraseTextStyle ?? this.arrivalPhraseTextStyle,
      buttonNegativeSurfaceColor:
          buttonNegativeSurfaceColor ?? this.buttonNegativeSurfaceColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      finishButtonTextStyle:
          finishButtonTextStyle ?? this.finishButtonTextStyle,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      iconSize: iconSize ?? this.iconSize,
      surfaceColorSecondary:
          surfaceColorSecondary ?? this.surfaceColorSecondary,
    );
  }
}
