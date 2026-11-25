import 'package:flutter/widgets.dart';

import './../../common/dgis_color_scheme.dart';
import './../../map/map_widget_color_scheme.dart';

class BetterRoutePromptTheme extends MapWidgetColorScheme {
  final Color acceptButtonIconColor;
  final Color acceptButtonIconColorBackground;
  final Color acceptButtonColor;
  final TextStyle acceptButtonTextStyle;
  final Color denyButtonColor;
  final TextStyle denyButtonTextStyle;
  final Color progressBarColor;

  const BetterRoutePromptTheme({
    required this.acceptButtonIconColor,
    required this.acceptButtonIconColorBackground,
    required this.acceptButtonColor,
    required this.acceptButtonTextStyle,
    required this.denyButtonColor,
    required this.denyButtonTextStyle,
    required this.progressBarColor,
  });

  static const defaultLight = BetterRoutePromptTheme(
    progressBarColor: Color(0x2B141414),
    acceptButtonIconColor: DgisColorScheme.brightBlue,
    acceptButtonIconColorBackground: DgisColorScheme.surfaceLight,
    acceptButtonColor: DgisColorScheme.brightBlue,
    acceptButtonTextStyle: TextStyle(
      color: DgisColorScheme.textColorOnBlue,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    denyButtonColor: DgisColorScheme.surfaceLight,
    denyButtonTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnLight,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  static const defaultDark = BetterRoutePromptTheme(
    progressBarColor: Color(0x2B141414),
    acceptButtonIconColor: DgisColorScheme.brightBlue,
    acceptButtonIconColorBackground: DgisColorScheme.surfaceLight,
    acceptButtonColor: DgisColorScheme.brightBlue,
    acceptButtonTextStyle: TextStyle(
      color: DgisColorScheme.textColorOnBlue,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    denyButtonColor: DgisColorScheme.surfaceDark,
    denyButtonTextStyle: TextStyle(
      color: DgisColorScheme.primaryTextColorOnDark,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  BetterRoutePromptTheme copyWith({
    Color? acceptButtonIconColor,
    Color? acceptButtonIconColorBackground,
    Color? acceptButtonColor,
    TextStyle? acceptButtonTextStyle,
    Color? denyButtonColor,
    TextStyle? denyButtonTextStyle,
    Color? progressBarColor,
  }) {
    return BetterRoutePromptTheme(
      acceptButtonIconColor: acceptButtonIconColor ?? this.acceptButtonColor,
      acceptButtonIconColorBackground:
          acceptButtonIconColorBackground ??
          this.acceptButtonIconColorBackground,
      acceptButtonColor: acceptButtonColor ?? this.acceptButtonColor,
      acceptButtonTextStyle:
          acceptButtonTextStyle ?? this.acceptButtonTextStyle,
      denyButtonColor: denyButtonColor ?? this.denyButtonColor,
      denyButtonTextStyle: denyButtonTextStyle ?? this.denyButtonTextStyle,
      progressBarColor: progressBarColor ?? this.progressBarColor,
    );
  }
}
