import 'package:flutter/material.dart';

import '../../map/map_widget_color_scheme.dart';

class RouteEditorViewTheme extends MapWidgetColorScheme {
  const RouteEditorViewTheme({
    required this.backgroundColor,
    required this.cardTheme,
    required this.tabTheme,
    required this.headerButtonBackground,
    required this.headerButtonColor,
    required this.startLabelTextStyle,
    required this.startPointColor,
    required this.finishLabelTextStyle,
    required this.finishPointColor,
    required this.routeLineColor,
    this.handleHeight = 16,
    this.routeListHeight = 100,
    this.routeListVerticalPadding = 16,
    this.tabBarHeight = 56,
    this.bottomPadding = 8,
    this.horizontalPadding = 16,
    this.cardWidth = 340,
    this.cardSpacing = 8,
  });

  final Color backgroundColor;
  final RouteCardTheme cardTheme;
  final RouteTabTheme tabTheme;

  final Color headerButtonBackground;
  final Color headerButtonColor;

  final TextStyle startLabelTextStyle;
  final Color startPointColor;

  final TextStyle finishLabelTextStyle;
  final Color finishPointColor;

  final Color routeLineColor;

  final double handleHeight;
  final double routeListHeight;
  final double routeListVerticalPadding;
  final double tabBarHeight;
  final double bottomPadding;
  final double horizontalPadding;
  final double cardWidth;
  final double cardSpacing;

  static const defaultLight = RouteEditorViewTheme(
    backgroundColor: Color(0xFFF1F1F1),
    cardTheme: RouteCardTheme.defaultLight,
    tabTheme: RouteTabTheme.defaultLight,
    headerButtonBackground: Color(0x0F141414),
    headerButtonColor: Color(0xFF5A5A5A),
    startLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    startPointColor: Color(0xFF1BA136),
    finishLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF000000),
      fontSize: 15,
      height: 1.3,
    ),
    finishPointColor: Color(0xFF0059D6),
    routeLineColor: Color(0xFF5A5A5A),
  );

  static const defaultDark = RouteEditorViewTheme(
    backgroundColor: Color(0xFF141414),
    cardTheme: RouteCardTheme.defaultDark,
    tabTheme: RouteTabTheme.defaultDark,
    headerButtonBackground: Color(0x0FFFFFFF),
    headerButtonColor: Color(0xFFB8B8B8),
    startLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    startPointColor: Color(0xFF26C947),
    finishLabelTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
    finishPointColor: Color(0xFF3588FD),
    routeLineColor: Color(0xFFB8B8B8),
  );

  @override
  RouteEditorViewTheme copyWith({
    Color? backgroundColor,
    RouteCardTheme? cardTheme,
    RouteTabTheme? tabTheme,
    Color? headerButtonBackground,
    Color? headerButtonColor,
    TextStyle? startLabelTextStyle,
    Color? startPointColor,
    TextStyle? finishLabelTextStyle,
    Color? finishPointColor,
    Color? routeLineColor,
    double? handleHeight,
    double? routeListHeight,
    double? routeListVerticalPadding,
    double? tabBarHeight,
    double? bottomPadding,
    double? horizontalPadding,
    double? cardWidth,
    double? cardSpacing,
  }) {
    return RouteEditorViewTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardTheme: cardTheme ?? this.cardTheme,
      tabTheme: tabTheme ?? this.tabTheme,
      headerButtonBackground:
          headerButtonBackground ?? this.headerButtonBackground,
      headerButtonColor: headerButtonColor ?? this.headerButtonColor,
      startLabelTextStyle: startLabelTextStyle ?? this.startLabelTextStyle,
      startPointColor: startPointColor ?? this.startPointColor,
      finishLabelTextStyle: finishLabelTextStyle ?? this.finishLabelTextStyle,
      finishPointColor: finishPointColor ?? this.finishPointColor,
      routeLineColor: routeLineColor ?? this.routeLineColor,
      handleHeight: handleHeight ?? this.handleHeight,
      routeListHeight: routeListHeight ?? this.routeListHeight,
      routeListVerticalPadding:
          routeListVerticalPadding ?? this.routeListVerticalPadding,
      tabBarHeight: tabBarHeight ?? this.tabBarHeight,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      cardWidth: cardWidth ?? this.cardWidth,
      cardSpacing: cardSpacing ?? this.cardSpacing,
    );
  }
}

/// Theme for route cards
class RouteCardTheme {
  const RouteCardTheme({
    required this.backgroundColor,
    required this.borderRadius,
    required this.durationTextStyle,
    required this.distanceTextStyle,
    required this.bestRouteBadgeBackground,
    required this.bestRouteBadgeTextStyle,
    required this.goButtonBackground,
    required this.goButtonRadius,
    required this.goButtonTextStyle,
  });

  final Color backgroundColor;
  final double borderRadius;

  final TextStyle durationTextStyle;
  final TextStyle distanceTextStyle;

  final Color bestRouteBadgeBackground;
  final TextStyle bestRouteBadgeTextStyle;

  final Color goButtonBackground;
  final double goButtonRadius;
  final TextStyle goButtonTextStyle;

  static const defaultLight = RouteCardTheme(
    backgroundColor: Color(0xFFFFFFFF),
    borderRadius: 12,
    durationTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF141414),
      fontSize: 19,
      height: 1.2,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    bestRouteBadgeBackground: Color(0x1A1DB93C),
    bestRouteBadgeTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1DB93C),
      fontSize: 13,
      height: 1.3,
    ),
    goButtonBackground: Color(0xFF1DB93C),
    goButtonRadius: 8,
    goButtonTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
  );

  static const defaultDark = RouteCardTheme(
    backgroundColor: Color(0x0FFFFFFF),
    borderRadius: 12,
    durationTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 19,
      height: 1.2,
    ),
    distanceTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 15,
      height: 1.3,
    ),
    bestRouteBadgeBackground: Color(0x1A1DB93C),
    bestRouteBadgeTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1DB93C),
      fontSize: 13,
      height: 1.3,
    ),
    goButtonBackground: Color(0xFF1DB93C),
    goButtonRadius: 8,
    goButtonTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFFFFFFFF),
      fontSize: 15,
      height: 1.3,
    ),
  );

  RouteCardTheme copyWith({
    Color? backgroundColor,
    double? borderRadius,
    TextStyle? durationTextStyle,
    TextStyle? distanceTextStyle,
    Color? bestRouteBadgeBackground,
    TextStyle? bestRouteBadgeTextStyle,
    Color? goButtonBackground,
    double? goButtonRadius,
    TextStyle? goButtonTextStyle,
  }) {
    return RouteCardTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      durationTextStyle: durationTextStyle ?? this.durationTextStyle,
      distanceTextStyle: distanceTextStyle ?? this.distanceTextStyle,
      bestRouteBadgeBackground:
          bestRouteBadgeBackground ?? this.bestRouteBadgeBackground,
      bestRouteBadgeTextStyle:
          bestRouteBadgeTextStyle ?? this.bestRouteBadgeTextStyle,
      goButtonBackground: goButtonBackground ?? this.goButtonBackground,
      goButtonRadius: goButtonRadius ?? this.goButtonRadius,
      goButtonTextStyle: goButtonTextStyle ?? this.goButtonTextStyle,
    );
  }
}

/// Theme for route type tabs (new design: horizontal layout with icon and text)
class RouteTabTheme {
  const RouteTabTheme({
    required this.inactiveIconColor,
    required this.inactiveTextStyle,
    required this.inactiveUnitTextStyle,
    required this.inactiveBackgroundColor,
    required this.activeIconColor,
    required this.activeTextStyle,
    required this.activeUnitTextStyle,
    required this.activeBackgroundColor,
    required this.activeShadow,
    required this.activeBorderColor,
    required this.activeBorderWidth,
    required this.borderRadius,
  });

  final Color inactiveIconColor;
  final TextStyle inactiveTextStyle;
  final TextStyle inactiveUnitTextStyle;
  final Color inactiveBackgroundColor;

  final Color activeIconColor;
  final TextStyle activeTextStyle;
  final TextStyle activeUnitTextStyle;
  final Color activeBackgroundColor;
  final List<BoxShadow> activeShadow;
  final Color activeBorderColor;
  final double activeBorderWidth;

  final double borderRadius;

  static const defaultLight = RouteTabTheme(
    inactiveIconColor: Color(0xFF898989),
    inactiveTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: -0.28,
    ),
    inactiveUnitTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 16 / 13,
      letterSpacing: -0.234,
    ),
    inactiveBackgroundColor: Colors.transparent,
    activeIconColor: Color(0xFF141414),
    activeTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: -0.28,
    ),
    activeUnitTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF141414),
      fontSize: 13,
      height: 16 / 13,
      letterSpacing: -0.234,
    ),
    activeBackgroundColor: Color(0xFFFFFFFF),
    activeShadow: [],
    activeBorderColor: Color(0xFF1BA136),
    activeBorderWidth: 1.5,
    borderRadius: 12,
  );

  static const defaultDark = RouteTabTheme(
    inactiveIconColor: Color(0xFF898989),
    inactiveTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: -0.28,
    ),
    inactiveUnitTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 16 / 13,
      letterSpacing: -0.234,
    ),
    inactiveBackgroundColor: Colors.transparent,
    activeIconColor: Color(0xFFFFFFFF),
    activeTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 14,
      height: 18 / 14,
      letterSpacing: -0.28,
    ),
    activeUnitTextStyle: TextStyle(
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
      fontSize: 13,
      height: 16 / 13,
      letterSpacing: -0.234,
    ),
    activeBackgroundColor: Color(0x1AFFFFFF),
    activeShadow: [],
    activeBorderColor: Color(0xFF26C947),
    activeBorderWidth: 1.5,
    borderRadius: 12,
  );

  RouteTabTheme copyWith({
    Color? inactiveIconColor,
    TextStyle? inactiveTextStyle,
    TextStyle? inactiveUnitTextStyle,
    Color? inactiveBackgroundColor,
    Color? activeIconColor,
    TextStyle? activeTextStyle,
    TextStyle? activeUnitTextStyle,
    Color? activeBackgroundColor,
    List<BoxShadow>? activeShadow,
    Color? activeBorderColor,
    double? activeBorderWidth,
    double? borderRadius,
  }) {
    return RouteTabTheme(
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      inactiveTextStyle: inactiveTextStyle ?? this.inactiveTextStyle,
      inactiveUnitTextStyle:
          inactiveUnitTextStyle ?? this.inactiveUnitTextStyle,
      inactiveBackgroundColor:
          inactiveBackgroundColor ?? this.inactiveBackgroundColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      activeTextStyle: activeTextStyle ?? this.activeTextStyle,
      activeUnitTextStyle: activeUnitTextStyle ?? this.activeUnitTextStyle,
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      activeShadow: activeShadow ?? this.activeShadow,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      activeBorderWidth: activeBorderWidth ?? this.activeBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
