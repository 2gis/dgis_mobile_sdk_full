import 'package:flutter/material.dart';

class WidgetShadows {
  // Используется как BoxShadow в круглых виджетах карты.
  static const mapWidgetBoxShadow = BoxShadow(
    color: Color(0x33141414),
    blurRadius: 3,
    offset: Offset(0, 2),
  );

  // Используется как BoxShadow в виджетах навигации.
  static const naviWidgetBoxShadowsLight = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 1,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const naviWidgetBoxShadowsDark = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      spreadRadius: 0.5,
    ),
  ];

  // Используется как BoxShadow в modern-виджетах карты.
  static const modernMapWidgetBoxShadows = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      spreadRadius: 0.5,
    ),
  ];
}
