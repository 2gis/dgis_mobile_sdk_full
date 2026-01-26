import 'package:flutter/material.dart';

class RoutePointsEditorTheme {
  const RoutePointsEditorTheme({
    required this.backgroundColor,
    required this.headerTitleTextStyle,
    required this.headerSubtitleTextStyle,
    required this.cancelButtonTextStyle,
    required this.pointLabelTextStyle,
    required this.addStopTextStyle,
    required this.addStopIconColor,
    required this.startPointColor,
    required this.intermediatePointColor,
    required this.finishPointColor,
    required this.routeLineColor,
    required this.deleteButtonColor,
    required this.dragHandleColor,
    required this.dividerColor,
    required this.handleColor,
  });

  final Color backgroundColor;
  final TextStyle headerTitleTextStyle;
  final TextStyle headerSubtitleTextStyle;
  final TextStyle cancelButtonTextStyle;
  final TextStyle pointLabelTextStyle;
  final TextStyle addStopTextStyle;
  final Color addStopIconColor;
  final Color startPointColor;
  final Color intermediatePointColor;
  final Color finishPointColor;
  final Color routeLineColor;
  final Color deleteButtonColor;
  final Color dragHandleColor;
  final Color dividerColor;
  final Color handleColor;

  static const defaultLight = RoutePointsEditorTheme(
    backgroundColor: Color(0xFFF1F1F1),
    headerTitleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFF141414),
      fontSize: 17,
      height: 1.3,
    ),
    headerSubtitleTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF898989),
      fontSize: 13,
      height: 1.3,
    ),
    cancelButtonTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF1BA136),
      fontSize: 17,
      height: 1.3,
    ),
    pointLabelTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF141414),
      fontSize: 17,
      height: 1.3,
    ),
    addStopTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF1BA136),
      fontSize: 17,
      height: 1.3,
    ),
    addStopIconColor: Color(0xFF1BA136),
    startPointColor: Color(0xFF1BA136),
    intermediatePointColor: Color(0xFF0059D6),
    finishPointColor: Color(0xFF0059D6),
    routeLineColor: Color(0xFF5A5A5A),
    deleteButtonColor: Color(0xFF898989),
    dragHandleColor: Color(0xFFD1D1D6),
    dividerColor: Color(0xFFE5E5EA),
    handleColor: Color(0x4D5A5A5A),
  );

  static const defaultDark = RoutePointsEditorTheme(
    backgroundColor: Color(0xFF141414),
    headerTitleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      fontSize: 17,
      height: 1.3,
    ),
    headerSubtitleTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF8E8E93),
      fontSize: 13,
      height: 1.3,
    ),
    cancelButtonTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF26C947),
      fontSize: 17,
      height: 1.3,
    ),
    pointLabelTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFFFFFFFF),
      fontSize: 17,
      height: 1.3,
    ),
    addStopTextStyle: TextStyle(
      fontWeight: FontWeight.w400,
      color: Color(0xFF26C947),
      fontSize: 17,
      height: 1.3,
    ),
    addStopIconColor: Color(0xFF26C947),
    startPointColor: Color(0xFF26C947),
    intermediatePointColor: Color(0xFF3588FD),
    finishPointColor: Color(0xFF3588FD),
    routeLineColor: Color(0xFFB8B8B8),
    deleteButtonColor: Color(0xFF8E8E93),
    dragHandleColor: Color(0xFF48484A),
    dividerColor: Color(0xFF38383A),
    handleColor: Color(0x4DB8B8B8),
  );

  RoutePointsEditorTheme copyWith({
    Color? backgroundColor,
    TextStyle? headerTitleTextStyle,
    TextStyle? headerSubtitleTextStyle,
    TextStyle? cancelButtonTextStyle,
    TextStyle? pointLabelTextStyle,
    TextStyle? addStopTextStyle,
    Color? addStopIconColor,
    Color? startPointColor,
    Color? intermediatePointColor,
    Color? finishPointColor,
    Color? routeLineColor,
    Color? deleteButtonColor,
    Color? dragHandleColor,
    Color? dividerColor,
    Color? handleColor,
  }) {
    return RoutePointsEditorTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerTitleTextStyle: headerTitleTextStyle ?? this.headerTitleTextStyle,
      headerSubtitleTextStyle:
          headerSubtitleTextStyle ?? this.headerSubtitleTextStyle,
      cancelButtonTextStyle:
          cancelButtonTextStyle ?? this.cancelButtonTextStyle,
      pointLabelTextStyle: pointLabelTextStyle ?? this.pointLabelTextStyle,
      addStopTextStyle: addStopTextStyle ?? this.addStopTextStyle,
      addStopIconColor: addStopIconColor ?? this.addStopIconColor,
      startPointColor: startPointColor ?? this.startPointColor,
      intermediatePointColor:
          intermediatePointColor ?? this.intermediatePointColor,
      finishPointColor: finishPointColor ?? this.finishPointColor,
      routeLineColor: routeLineColor ?? this.routeLineColor,
      deleteButtonColor: deleteButtonColor ?? this.deleteButtonColor,
      dragHandleColor: dragHandleColor ?? this.dragHandleColor,
      dividerColor: dividerColor ?? this.dividerColor,
      handleColor: handleColor ?? this.handleColor,
    );
  }
}
